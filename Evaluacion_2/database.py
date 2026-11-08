from motor.motor_asyncio import AsyncIOMotorClient

# Conexión centralizada a la base de datos
client = AsyncIOMotorClient("mongodb://localhost:27017")
db = client.mr_sandwich_db