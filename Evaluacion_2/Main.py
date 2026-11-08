from fastapi import FastAPI
import strawberry
from strawberry.fastapi import GraphQLRouter
from bson import ObjectId
from database import db

# Importación de los microservicios separados
from clients.rutas import router as clients_router
from inventory.rutas import router as inventory_router
from orders.rutas import router as orders_router
from payments.rutas import router as payments_router

app = FastAPI(title="Mr. Sandwich API Gateway")

# Enrutamiento hacia los microservicios (Módulos 3 y 5)
app.include_router(clients_router)
app.include_router(inventory_router)
app.include_router(orders_router)
app.include_router(payments_router)

# --- Agregación GraphQL Privada (Módulo 8) ---
@strawberry.type
class ClienteGQL:
    nombre_usuario: str
    email: str

@strawberry.type
class PedidoGQL:
    id: str
    total: int
    estado: str
    cliente_info: ClienteGQL

@strawberry.type
class Query:
    @strawberry.field
    async def ver_detalle_pedido(self, pedido_id: str) -> PedidoGQL:
        pedido_db = await db.orders.find_one({"_id": ObjectId(pedido_id)})
        if not pedido_db:
            raise Exception("Pedido no encontrado")
        
        cliente_db = await db.clients.find_one({"email": pedido_db["email_cliente"]})
        cliente_obj = ClienteGQL(
            nombre_usuario=cliente_db["nombre_usuario"] if cliente_db else "Desconocido",
            email=pedido_db["email_cliente"]
        )
        
        return PedidoGQL(
            id=str(pedido_db["_id"]),
            total=pedido_db["total"],
            estado=pedido_db["estado"],
            cliente_info=cliente_obj
        )

schema = strawberry.Schema(query=Query)
graphql_app = GraphQLRouter(schema)
app.include_router(graphql_app, prefix="/graphql")