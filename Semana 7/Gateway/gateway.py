from fastapi import FastAPI
import httpx 
app = FastAPI(title="Local API GATEWAY")

MAIN = "http://localhost:8481/" #fastapi

@app.get("/api/items")
async def get_items():
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{MAIN}/items"
        )
    return response.json()

@app.get("/api/ordenes")
async def get_ordenes():
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{MAIN}/ordenes"
        )
    return response.json()
