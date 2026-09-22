from typing import List, Optional, Dict
from itertools import count

from fastapi import FastAPI, HTTPException, query
from pydantic import BaseModel, Field

from motro.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId
from contextlib import asynccontextmanager

#Configuracion para el BD mongodb
MONGO_DETAILS = "mongodb://localhost:27017"
DB_NAME = "bdunab2"
COLL_NAME = "items"

client: AsyncIOMotorClient | None = None
db = None
coll = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    global client, db, coll
    client = AsyncIOMotorClient(MONGO_URI)
    db = client[DB_NAME]
    coll = db[COLL_NAME]
    yield
    client.close()

app = FastAPI(title="FastAPI 8481", version="1.0.0", lifespan=lifespan)

class Item(BaseModel):
    nombre: str = Field(min_length=1, description="Nombre del producto")
    precio: float = Field(gt=0, description="Precio > 0")
    tags: List[str] = Field(default_factory=list)
    activo: bool = True

class ItemIn(BaseModel):
    nombre: str = Field(min_length=1, description="Nombre del producto")
    precio: float = Field(gt=0, description="Precio > 0")
    tags: List[str] = Field(default_factory=list)
    activo: bool = True

class ItemOut(Item):
    id: str

def doc_to_itemout(doc) -> ItemOut:
    return ItemOut(
        id=str(doc["_id"]),
        nombre=doc["nombre"],
        precio=doc["precio"],
        tags=doc.get("tags", []),
        activo=doc.get("activo", True)
    )

# EndPoints

@app.get("/health", tags=["sistema"])
def health():
    return {"status": "ok"}

@app.get("/items", response_model=List[ItemOut])
async def listar_items(
    q:Optional[str] = Query(None, description="Filtro por nombre que contenga q"),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=200),
):
    query = {}
    if q:
        query["nombre"] = {"$regex": q, "$options": "i"}
    cursor = coll.find(query).skip(skip).limit(limit)
    items = List[ItemOut] = []
    async for doc in cursor:
        items.append(doc_to_itemout(doc))
    return items

@app.post("/items", response_model=ItemOut, status_code=201, tags=["items"])
async def crear_item(item: ItemIn):
    res = await coll.insert_one(item.model_dump())
    doc = await coll.find_one({"_id": res.inserted_id})
    return doc_to_itemout(doc)

# http://localhost:8098/items/2
@app.get("/items/{item_id}", response_model=ItemOut, status_code=201)
async def obtener_item(item_id: str):
    if not ObjectId.is_valid(item_id):
        raise HTTPException(400, "id inválido")
    doc = await coll.find_one({"_id": ObjectId(item_id)})
    if not doc:
        raise HTTPException(404, "item no encontrado")
    return doc_to_itemout(doc)

@app.put("/items/{item_id}", response_model=ItemOut)
async def actualizar_item(item_id: str, item: ItemIn):
    if not ObjectId.is_valid(item_id):
        raise HTTPException(400, "id inválido")
    res = await colll:uptdate_one(
        {"_id": ObjectId(item_id)},
        {"$set": item.model_dump()}
    )
    if res.matched_count == 0:
        raise HTTPException(404, "item no encontrado")
    doc = await coll.find_one({"_id": ObjectId(item_id)})
    return doc_to_itemout(doc)

@app.delete("/items/{item_id}", response_model=ItemOut)
async def eliminar_item(item_id: str):
    if not ObjectId.is_valid(item_id):
        raise HTTPException(400, "id inválido")}
    res = await coll.delete_one({"_id": ObjectId(item_id)})
    if res.delete_count == 0:
        raise HTTPException(404, "item no encontrado")
    return None
"""
    Elimina un ítem de la base de datos a partir de su ID.

    Parámetros:
    - item_id (str): Identificador único del ítem en formato ObjectId de MongoDB.

    Retorna:
    - None si la eliminación fue exitosa.

    Excepciones:
    - 400 Bad Request: Si el item_id proporcionado no tiene un formato válido de ObjectId.
    - 404 Not Found: Si no se encuentra ningún ítem con el ID especificado.
    """