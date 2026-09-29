import os
import secrets
import httpx

from fastapi import (
    FastAPI,
    Depends,
    HTTPException
)

from fastapi.security import (
    HTTPBearer,
    HTTPAuthorizationCredentials
)


# CONFIGURACIÓN DE LA API GATEWAY

app = FastAPI(
    title="Local API GATEWAY",
    description="API Gateway con Vault, autenticacion y autorizacion por roles"
)

security = HTTPBearer(auto_error=False)


# CONFIGURACIÓN DE VAULT

VAULT_ADDR = os.getenv(
    "VAULT_ADDR",
    "http://127.0.0.1:8200"
)

VAULT_TOKEN = os.getenv(
    "VAULT_TOKEN"
)


# CONFIGURACIÓN DEL BACKEND

MAIN = os.getenv(
    "BACKEND_URL",
    "http://localhost:8481"
)


# VALIDACIÓN DE CONFIGURACIÓN

if not VAULT_TOKEN:
    raise RuntimeError(
        "VAULT_TOKEN no configurado"
    )


# OBTENER SECRETOS DESDE VAULT

async def get_gateway_secrets():
    """
    RECUPERA DESDE VAULT:
    - TOKEN_USUARIO
    - TOKEN_ADMIN
    - BACKEND_SHARED_SECRET
    """

    url = f"{VAULT_ADDR}/v1/secret/data/gateway"

    headers = {
        "X-Vault-Token": VAULT_TOKEN
    }

    try:
        async with httpx.AsyncClient(
            timeout=5.0
        ) as client:

            response = await client.get(
                url,
                headers=headers
            )

    except httpx.RequestError:
        raise HTTPException(
            status_code=500,
            detail="No fue posible conectarse a Vault"
        )

    if response.status_code != 200:
        raise HTTPException(
            status_code=500,
            detail="No fue posible acceder a Vault"
        )

    try:
        vault_data = response.json()["data"]["data"]

    except (KeyError, TypeError, ValueError):
        raise HTTPException(
            status_code=500,
            detail="Respuesta invalida de Vault"
        )

    required_secrets = [
        "token_usuario",
        "token_admin",
        "backend_shared_secret"
    ]

    for secret_name in required_secrets:
        if not vault_data.get(secret_name):
            raise HTTPException(
                status_code=500,
                detail=f"Falta el secreto '{secret_name}' en Vault"
            )

    return vault_data


# AUTENTICACIÓN Y AUTORIZACIÓN

async def authenticate_and_authorize(
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """
    VERIFICA EL BEARER TOKEN Y DETERMINA EL ROL DEL CLIENTE.
    """

    # NO SE ENVIÓ TOKEN

    if credentials is None:
        raise HTTPException(
            status_code=401,
            detail="Bearer token requerido"
        )

    # OBTENER SECRETOS

    vault_secrets = await get_gateway_secrets()

    token_usuario = vault_secrets["token_usuario"]
    token_admin = vault_secrets["token_admin"]
    backend_secret = vault_secrets["backend_shared_secret"]

    received_token = credentials.credentials


    # COMPROBAR TOKEN DE ADMINISTRADOR

    if secrets.compare_digest(
        received_token,
        token_admin
    ):
        return {
            "role": "administrador",
            "backend_secret": backend_secret
        }


    # COMPROBAR TOKEN DE USUARIO

    if secrets.compare_digest(
        received_token,
        token_usuario
    ):
        return {
            "role": "usuario",
            "backend_secret": backend_secret
        }


    # TOKEN INVÁLIDO

    raise HTTPException(
        status_code=401,
        detail="Token invalido"
    )


# HEALTH CHECK DEL GATEWAY

@app.get("/health")
def health():
    return {
        "status": "OK",
        "service": "API Gateway"
    }


# ENDPOINT DE PRODUCTOS

@app.get("/api/productos")
async def get_productos(
    auth: dict = Depends(authenticate_and_authorize)
):

    # USUARIO Y ADMINISTRADOR TIENEN PERMISO

    gateway_headers = {
        "X-Gateway-Secret": auth["backend_secret"]
    }

    try:
        async with httpx.AsyncClient(
            timeout=10.0
        ) as client:

            response = await client.get(
                f"{MAIN}/productos",
                headers=gateway_headers
            )

    except httpx.RequestError:
        raise HTTPException(
            status_code=502,
            detail="Backend no disponible"
        )


    # DEVOLVER LA RESPUESTA DEL BACKEND

    if response.status_code != 200:
        raise HTTPException(
            status_code=response.status_code,
            detail="El backend rechazo la solicitud"
        )

    return response.json()


# ENDPOINT DE ÓRDENES

@app.get("/api/ordenes")
async def get_ordenes(
    auth: dict = Depends(authenticate_and_authorize)
):

    # SOLO ADMINISTRADOR TIENE PERMISO

    if auth["role"] != "administrador":
        raise HTTPException(
            status_code=403,
            detail="Acceso denegado. Se requiere rol de administrador."
        )


    # ENVIAR SECRETO INTERNO AL BACKEND

    gateway_headers = {
        "X-Gateway-Secret": auth["backend_secret"]
    }

    try:
        async with httpx.AsyncClient(
            timeout=10.0
        ) as client:

            response = await client.get(
                f"{MAIN}/ordenes",
                headers=gateway_headers
            )

    except httpx.RequestError:
        raise HTTPException(
            status_code=502,
            detail="Backend no disponible"
        )


    # DEVOLVER LA RESPUESTA DEL BACKEND

    if response.status_code != 200:
        raise HTTPException(
            status_code=response.status_code,
            detail="El backend rechazo la solicitud"
        )

    return response.json()