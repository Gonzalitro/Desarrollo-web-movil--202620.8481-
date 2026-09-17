from fastapi import FastAPI


app = FastAPI(
    title="Backend API es",
    description="API ubicada y enrutada por API gateway"
)

@app.get("/health")
def health():
    return {
        "status": "OK",
        "service": "Backend API"
    }

@app.get("/productos")
def productos():
    return {
        "productos": [
            {"id": 1, "nombre": "Acerrin", "precio": 1000},
            {"id": 2, "nombre": "Monitor", "precio": 2000},
            {"id": 3, "nombre": "Aceite", "precio": 9000},
            {"id": 4, "nombre": "Carroza desmontada", "precio": 250000}
        ]
    }

@app.get("/ordenes")
def ordenes():
    return {
        "ordenes": [
            {"id": 1001, "status": "paid"},
            {"id": 1002, "status": "pending"},
            {"id": 1003, "status": "pending"},
            {"id": 1004, "status": "pending"},
            {"id": 1005, "status": "pending"},
        ]
    }