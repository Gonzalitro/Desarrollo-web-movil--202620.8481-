from fastapi import APIRouter
from pydantic import BaseModel
from bson import ObjectId
from database import db

router = APIRouter(prefix="/api/payments", tags=["Payments"])

class PagoCreate(BaseModel):
    pedido_id: str
    monto_total: int

@router.post("/procesar")
async def procesar_pago(pago: PagoCreate):
    nuevo_pago = {"pedido_id": pago.pedido_id, "monto_total": pago.monto_total, "estado": "Aprobado"}
    await db.payments.insert_one(nuevo_pago)
    await db.orders.update_one({"_id": ObjectId(pago.pedido_id)}, {"$set": {"estado": "pagado"}})
    return {"mensaje": "Pago procesado exitosamente"}