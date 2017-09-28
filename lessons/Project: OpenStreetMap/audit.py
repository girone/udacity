""" audit.py

Parses data from an OSM XML file and saves a JSON file ready to be imported
into MongoDB:

    mongoimport -d udacity_dand -c osm_dresden dresden_germany.osm.json
    
"""
from collections import Counter, defaultdict
import json
import xml.etree.cElementTree as ET
import re
import codecs
from math import sin, cos, sqrt, atan2, radians


filename = 'dresden_germany.sample_k=100.osm'
#filename = 'dresden_germany.sample_k=10.osm'
#filename = 'dresden_germany.osm'

TOP_LEVEL_TAGS = ["way", "node"]
CREATED = ["version", "changeset", "timestamp", "user", "uid"]

problemchars = re.compile(r'[=\+/&<>;\'"\?%#$@\,\. \t\r\n]')


# Stores node coordinates for distance calculation.
NODE_LOCATIONS = {}


# Count tag keys per parent element type (e.g. "node", "way", ...).
tag_keys = defaultdict(Counter)
element_counter = Counter()


def pairwise(iterable):
    "s -> (s0,s1), (s1,s2), (s2, s3), ..."
    from itertools import tee
    a, b = tee(iterable)
    next(b, None)
    return zip(a, b)


def geo_distance(lat1, lon1, lat2, lon2):
    """Compute the distance between two points on the earth given by latitude and longitude.
    
    Courtes of https://stackoverflow.com/a/19412565/841567.
    """
    # approximate radius of earth in km
    R = 6373.0

    lat1 = radians(lat1)
    lon1 = radians(lon1)
    lat2 = radians(lat2)
    lon2 = radians(lon2)

    dlon = lon2 - lon1
    dlat = lat2 - lat1

    a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))

    distance = R * c
    return distance


def compute_way_length(way):
    """Assumes that the way nodes are in the correct order."""
    distance = 0
    for s, t in pairwise(way):
        try:
            lat1, lon1 = NODE_LOCATIONS[s]
            lat2, lon2 = NODE_LOCATIONS[t]
            distance += geo_distance(lat1, lon1, lat2, lon2)
        except:
            pass  # ignore errors, which happens a lot in sampled data
    return distance

    
def parse_address(element):
    address = {}
    for subtag in element.iter("tag"):
        k = subtag.attrib["k"]
        v = subtag.attrib["v"]
        if problemchars.match(k):
            print(k)
            continue
        elif k.count(":") > 1:
            continue
        elif k.startswith("addr:"):
            key = k.split(":")[1]
            address[key] = v
    return address
        
    
# Maps each type of special information to a list of fields which we care for.
SPECIAL_TYPES = {"shop": ["name", "wheelchair", "opening_hours"]}

    
def parse_specials(element):
    """Parses and restructures special information for nodes."""
    content = {}
    type_ = None
    for subtag in element.iter("tag"):
        k = subtag.attrib["k"]
        v = subtag.attrib["v"]
        if k in SPECIAL_TYPES:
            type_ = k
        else:
            content[k] = v
    content = {k: v for k, v in content.items() 
               if type_ in SPECIAL_TYPES and k in SPECIAL_TYPES[type_]}       
    
    return type_, content
    
    
def parse_node(element):
    node = {}
    element_counter["node"] += 1
    address = parse_address(element)
    if address:
        node["address"] = address
    special_type, special_content = parse_specials(element)
    if special_type:
        node[special_type] = special_content
    return node


def parse_way_nodes(element):
    nodes = []
    for node in element.iter("nd"):
        nodes.append(node.attrib["ref"])
    return nodes     


def parse_way(element):
    way = {}
    element_counter["way"] += 1
    way_nodes = parse_way_nodes(element)
    if way_nodes:
        way["nodes"] = way_nodes    
        way["length"] = compute_way_length(way_nodes)
    return way


def parse_tags(element):
    tags = {}
    for tag in element.iter("tag"):
        #print("tag", tag.attrib)
        k, v = tag.attrib["k"], tag.attrib["v"]
        if k.startswith("addr:"):
            continue  # skip address tags, will be parsed otherwise
        tags[k] = v
    return tags


common_street_names = re.compile(
        r"(weg|straße|platz|allee|gasse|ring|berg|grund|" +
        r"steig|hof|ufer|höhe|leite|brücke|passage|steg|graben|tunnel)", 
        re.IGNORECASE)
common_start_phrases = re.compile(
        r"(Am |An de|Alt|Hinter de|Im |Zum |Zur )", 
        re.IGNORECASE)


def is_valid_street_name(name):
    return common_street_names.search(name) or common_start_phrases.match(name)


def extract_street_name_component(name):
    match = common_street_names.search(name)
    if match:
        return match.group(1).lower()
    match = common_start_phrases.match(name)
    if match:
        return match.group(1).lower()
    return ""


def parse_element(element):
    entity = None
    if element.tag == "way":
        entity = parse_way(element)
    elif element.tag == "node":
        entity = parse_node(element)
    entity["created"] = {}
    entity["type"] = element.tag
    lat = lon = None
    for k, v in element.attrib.items():
        if k in CREATED:
            # ignore the creation data
            pass
        elif k == "lat":
            lat = float(v)
        elif k == "lon":
            lon = float(v)
        else:
            entity[k] = v
    if lat and lon:
        entity["pos"] = [lat, lon]
        NODE_LOCATIONS[entity["id"]] = [lat, lon]
        
    # Parse the tags.
    tags = parse_tags(element)
    entity["tags"] = tags if tags else {}

    # For ways, only consider streets (highway tag) with a valid name:
    if element.tag == "way":
        tags = entity["tags"]
        if ("highway" in tags and 
            "name" in tags and 
            is_valid_street_name(tags["name"])):
            string = extract_street_name_component(tags["name"])
            entity["street_name_component_match"] = string
            return entity
        else:
            return None
    return entity

    
filename_out = "{0}.json".format(filename)
with open(filename) as f:
    with codecs.open(filename_out, "w") as fout:
        for event, element in ET.iterparse(f, events=["end"]):
            if element.tag in TOP_LEVEL_TAGS:
                #print(element)
                el = parse_element(element)
                if el:
                    #fout.write(json.dumps(el, indent=2) + "\n")
                    fout.write(json.dumps(el) + "\n")
        print("Wrote to {}".format(filename_out))


def main():
    create_statistics()


if __name__ == "__main__":
    main()