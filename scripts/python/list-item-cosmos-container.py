#!/usr/bin/env python3

from azure.cosmos import CosmosClient
import os

URL = os.environ['ACCOUNT_URI']
KEY = os.environ['ACCOUNT_KEY']
DATABASE_NAME = 'lab-az900'
CONTAINER_NAME = 'lab-az900'

print("List item in Cosmos Database " + DATABASE_NAME +" in Conteiner" + CONTAINER_NAME)
print ("----------------------------------------------------")

client = CosmosClient(URL, credential=KEY)
database = client.get_database_client(DATABASE_NAME)
container = database.get_container_client(CONTAINER_NAME)

# Enumerate the returned items
import json
for item in container.query_items(
        query='SELECT * FROM mycontainer r WHERE r.id="command5"',
        enable_cross_partition_query=True):
    print(json.dumps(item, indent=True))