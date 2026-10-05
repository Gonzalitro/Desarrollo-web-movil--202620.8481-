from datetime import datetime, timedelta, timezone
import secrets
import os
from fastapi import FastAPI, HTTPException, Header
from pydantic import BaseModel
app = FastAPI(
    title="Authentication Service",
    description="Servicio simple de autenticación y emisión de tokens"
)

# Base de datos simulada de usuarios
USERS = {
    "ana": {
        "password": "1234",
        "user_id": "USR-001",
        "roles": "user"
    },
    "pedro": {
        "password": "5678",
        "user_id": "USR-002",
        "roles": "user"
    },
    "ernesto": {
        "password": "admin123",
        "user_id": "USR-003",
        "roles": ["user", "admin"]
    }
}

# Diccionario para guardar las sesiones activas en memoria
SESSIONS = {}
TOKEN_LIFETIME_MINUTES = 15

# Secreto para validar que la consulta viene del Gateway
AUTH_INTROSPECTION_SECRET = os.getenv(
    "AUTH_INTROSPECTION_SECRET", "gateway-auth-secret-789"
)

# Modelos de datos de entrada (Pydantic)
class LoginRequest(BaseModel):
    username: str
    password: str

class IntrospectionRequest(BaseModel):
    token: str

@app.post("/login")
def login(request: LoginRequest):
    user = USERS.get(request.username)
    
    # Validaciones de usuario y contraseña
    if user is None:
        raise HTTPException(status_code=401, detail="Usuario incorrecto")
        
    if user["password"] != request.password:
        raise HTTPException(status_code=401, detail="Credenciales incorrectas")

    # Generación de token y fecha de expiración
    access_token = secrets.token_urlsafe(32)
    expiration = datetime.now(timezone.utc) + timedelta(minutes=TOKEN_LIFETIME_MINUTES)

    # Guardar la sesión
    SESSIONS[access_token] = {
        "user_id": user["user_id"],
        "username": request.username,
        "roles": user["roles"],
        "expires_at": expiration.isoformat()
    }

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "expires_in": TOKEN_LIFETIME_MINUTES * 60
    }

@app.get("/health")
def health():
    return {
        "status": "OK",
        "service": "Authentication Service"
    }