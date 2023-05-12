#!/usr/bin/env python3

from azure.cosmos import CosmosClient
import os

# Variables
URL = os.environ['ACCOUNT_URI']
KEY = os.environ['ACCOUNT_KEY']
DATABASE_NAME = 'lab-az900'
CONTAINER_NAME = 'lab-az900'
client = CosmosClient(URL, credential=KEY)
database = client.get_database_client(DATABASE_NAME)
container = database.get_container_client(CONTAINER_NAME)

print("Insert item in Cosmos Database " + DATABASE_NAME +" in Conteiner" + CONTAINER_NAME)
print ("----------------------------------------------------")
for i in range(1, 10):
    container.upsert_item({
            'id': 'command{0}'.format(i),
            'commandName': 'az',
            'example': 'az {0}'.format(i)
        }
    )