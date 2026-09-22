from typing import list, optional, dict
from itertools import count

from fastapi import FastAPI, HTTPException, query
from pydantic import baseModel, field 

from motor.motor_asyncio import AsyncIOMotorClient
from bson import objectId 
from contextlib import asynccontextmanager

#configuration BD mongodb 
MONGODB_URI = "mongodb://localhost:27017"
DB_NAME = "bdunab2"
COLL_NAME = "items"

client: AsyncIOMotorClient | None = None
db = none 
coll = none

@asynccontextmanager
async def lifespan(app: FastAPI):
    global client, db, coll
    client = AsyncIOMotorClient(MONGODB_URI)
    db = client[DB_NAME]
    coll = db[COLL_NAME]
