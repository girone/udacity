""" statistics.py

Creates statistics from a OSM data set in Mongodb.
"""
from pymongo import MongoClient
from bson.code import Code
from pprint import pprint


def create_statistics():
    client = MongoClient("localhost:27017")
    #print(client.database_names())
    db = client.udacity_dand

    print("Most frequent shops in town:")
    result = db.osm_dresden.aggregate([
        {"$match": {"shop": {"$exists": True}}},  # select only shop nodes
        {"$group": {"_id": "$shop.name", "count": {"$sum": 1}}},  # group by shop name
        {"$sort": {"count": -1}},  # sort descending by number of occurrences
        {"$limit": 10}  # show only the top 10
    ])
    print("| Name | Count |")
    print("|-|-|")
    for entry in result:
        print("|{}|{}|".format(entry["_id"], entry["count"]))
    print()

    print("Longest streets:")
    result = db.osm_dresden.aggregate([
        {"$match": {"type": {"$eq": "way"}}},  # select only ways
        {"$sort": {"length": -1}},  # sort by lenght, descending
        {"$project": {"_id": 0, "tags.name": 1, "length": 1}},  # include only these two fields into the result
        {"$limit": 10}  # show only 10
    ])
    print("| Street name | lenth in kilometers |")
    print("|-|-|")
    for entry in result:
        print("|{}|{:.3}|".format(entry["tags"]["name"], entry["length"]))
    print()


    print("Streets with the most nodes:")
    result = db.osm_dresden.aggregate([
        {"$match": {"type": {"$eq": "way"}}},  # select only ways
        {"$project": {"_id": 0, "tags.name": 1, "elements": {"$size": "$nodes"}}},  # include only the name and compute the number of nodes
        {"$sort": {"elements": -1}},  # sort by lenght, descending
        {"$limit": 10}  # show only 10
    ])
    print("| Street name | number of nodes |")
    print("|-|-|")
    for entry in result:
        print("|{}|{}|".format(entry["tags"]["name"], entry["elements"]))
    print()

    print("Frequency of common street name components:")
    # First try was with MapReduce in MongoDB, however, doing the pattern matching in Python
    # while auditing the data was so much easiert and simpler to debug.
    # mapFunction = Code("""function () {
    #     var regex = /(weg|straße|platz|allee|gasse|ring|berg|grund|steig|hof|ufer|höhe|leite|brücke|passage|steg|graben|tunnel)/gi;
    #     var street_name_match = regex.exec(this.tags.name)[0];
    #     var value = 1;
    #     emit( street_name_match, value );
    # };""")
    # reduceFunction = Code("""function (key, values) {
    #     var reducedObject = {
    #         _id: key,
    #         count: 0
    #     };
    #     values.forEach( function(value) {
    #         reducedObject.count += value;
    #     });
    #     return reducedObject;
    # };""")
    # preselectQuery = """{"$and": [{"type": {"$eq": "way"}}, {"tags.name": {"$exists": true}}]}"""
    # db.osm_dresden.map_reduce(mapFunction, reduceFunction, "mapReduceResult", query=preselectQuery)

    result = db.osm_dresden.aggregate([
        {"$match": {"type": {"$eq": "way"}}},  # select only ways
        {"$group": {"_id": "$street_name_component_match", "count": {"$sum": 1}}},  # group by street name component
        {"$sort": {"count": -1}},  # sort by field "count", descending
    ])
    print("| Street name component | absolute frequency |")
    print("|-|-|")
    for entry in result:
        print("|{}|{}|".format(entry["_id"], entry["count"]))
    print()


def main():
    create_statistics()


if __name__ == "__main__":
    main()