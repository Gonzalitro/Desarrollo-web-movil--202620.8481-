from fastapi import APIRouter
from database import db

router = APIRouter(prefix="/api/inventory", tags=["Inventory"])

@router.get("/productos")
async def obtener_catalogo():
    if await db.inventory.count_documents({}) == 0:
        productos_iniciales = [
            {"nombre": "Sandwich Umami", "precio": 6500, "stock": 50},
            {"nombre": "Wrap Carne asada", "precio": 7500, "stock": 30},
            {"nombre": "Papas fritas", "precio": 8500, "stock": 100},
            {"nombre": "Cocacola en lata", "precio": 2500, "stock": 200}
        ]
        await db.inventory.insert_many(productos_iniciales)
    
    cursor = db.inventory.find({}, {"_id": 0})
    productos = await cursor.to_list(length=100)
    return {"catalogo": productos}