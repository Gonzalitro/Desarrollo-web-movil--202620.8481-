from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import List
from database import db
from clients.rutas import verificar_usuario

router = APIRouter(prefix="/api/orders", tags=["Orders"])

class ItemCarrito(BaseModel):
    nombre: str
    precio: int
    cantidad: int

class PedidoCreate(BaseModel):
    items: List[ItemCarrito]
    total: int

@router.post("/crear", status_code=201)
async def crear_pedido(pedido: PedidoCreate, email_actual: str = Depends(verificar_usuario)):
    nuevo_pedido = {
        "email_cliente": email_actual,
        "items": [item.dict() for item in pedido.items],
        "total": pedido.total,
        "estado": "pendiente"
    }
    resultado = await db.orders.insert_one(nuevo_pedido)
    return {"mensaje": "Pedido creado", "pedido_id": str(resultado.inserted_id)}