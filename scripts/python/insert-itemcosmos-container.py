#!/usr/bin/env python3

from azure.cosmos import CosmosClient, PartitionKey, exceptions
import os

# Variables
COSMOSDATABASENAME = "lab-az900"
COSMOSCONTEINERNAME = "lab-az900"

print("Insert item in Cosmos Database " + COSMOSDATABASENAME +
      " in Conteiner" + COSMOSCONTEINERNAME)

url = os.environ['ACCOUNT_URI']
key = os.environ['ACCOUNT_KEY']
client = CosmosClient(url, credential=key)

database_client = client.get_database_client("lab-az900")
container_client = client.get_container_client("lab-az900")

# for i in range(1, 10):
#     container_client.upsert_item({
#         'id': 'item{0}'.format(i),
#         'command': 'az vm',
#         'example': 'az vm {0}'.format(i)
#     }
#     )
