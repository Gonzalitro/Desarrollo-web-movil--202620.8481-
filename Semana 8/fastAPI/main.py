import os
import secrets

from fastapi import FastAPI, Header, HTTPException, Depends


# CONFIGURACIÓN DE LA API

app = FastAPI(
    title="Backend API",
    description="API ubicada y protegida detrás del API Gateway"
)

# SECRETO INTERNO DEL API GATEWAY

INTERNAL_GATEWAY_SECRET = os.getenv(
    "INTERNAL_GATEWAY_SECRET"
)

if not INTERNAL_GATEWAY_SECRET:
    raise RuntimeError(
        "INTERNAL_GATEWAY_SECRET no esta configurado"
    )


# VALIDACIÓN DEL GATEWAY

def verify_gateway(
    x_gateway_secret: str = Header(default="")
):
    """
    Verifica que la petición haya sido enviada
    por el API Gateway.

    El Gateway debe enviar:
        X-Gateway-Secret: <secreto>
    """

    is_valid = secrets.compare_digest(
        x_gateway_secret,
        INTERNAL_GATEWAY_SECRET
    )

    if not is_valid:
        raise HTTPException(
            status_code=403,
            detail="Solicitud no autorizada desde Gateway"
        )


# HEALTH CHECK

@app.get("/health")
def health():
    return {
        "status": "OK",
        "service": "Backend API"
    }

# PRODUCTOS

@app.get(
    "/productos",
    dependencies=[Depends(verify_gateway)]
)
def productos():
    return {
        "productos": [
            {
                "id": 1,
                "nombre": "Acerrin",
                "precio": 1000
            },
            {
                "id": 2,
                "nombre": "Monitor",
                "precio": 2000
            },
            {
                "id": 3,
                "nombre": "Aceite",
                "precio": 9000
            },
            {
                "id": 4,
                "nombre": "Carroza desmontada",
                "precio": 250000
            }
        ]
    }


# ÓRDENES

@app.get(
    "/ordenes",
    dependencies=[Depends(verify_gateway)]
)
def ordenes():
    return {
        "ordenes": [
            {
                "id": 1001,
                "status": "paid"
            },
            {
                "id": 1002,
                "status": "pending"
            },
            {
                "id": 1003,
                "status": "pending"
            },
            {
                "id": 1004,
                "status": "pending"
            },
            {
                "id": 1005,
                "status": "pending"
            }
        ]
    }