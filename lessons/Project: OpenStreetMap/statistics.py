from pymongo import MongoClient
from pprint import pprint


def create_statistics():
    client = MongoClient("localhost:27017")
    print("#"*5)
    print(client.database_names())
    db = client.udacity_dand

    #for entry in db.osm_dresden.find({"shop": {"$exists": True}}):
    #    pprint(entry)

    result = db.osm_dresden.aggregate([
        {"$match": {"shop": {"$exists": True}}},
        {"$group": {"_id": "$shop.name", "count": {"$sum": 1}}},
        {"$sort": {"count": -1}},
        {"$limit": 10}
    ])

    pprint(result)

    for entry in result:
        pprint(entry)





def main():
    create_statistics()


if __name__ == "__main__":
    main()