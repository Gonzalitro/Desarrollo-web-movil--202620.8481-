from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel, EmailStr
from passlib.context import CryptContext
import jwt
from datetime import datetime, timedelta
from database import db

router = APIRouter(prefix="/api/clients", tags=["Clients"])

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
SECRET_KEY = "clave_secreta_mr_sandwich_2026"
ALGORITHM = "HS256"
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/clients/login")

def crear_token(email: str):
    expiracion = datetime.utcnow() + timedelta(hours=2)
    return jwt.encode({"sub": email, "exp": expiracion}, SECRET_KEY, algorithm=ALGORITHM)

async def verificar_usuario(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email = payload.get("sub")
        if email is None:
            raise HTTPException(status_code=401, detail="Token inválido")
        return email
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Token expirado o inválido")

class UserCreate(BaseModel):
    nombre_usuario: str
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

@router.post("/register", status_code=status.HTTP_201_CREATED)
async def registrar_cliente(user: UserCreate):
    if await db.clients.find_one({"email": user.email}):
        raise HTTPException(status_code=400, detail="El correo ya está registrado")
    hashed_password = pwd_context.hash(user.password)
    nuevo_cliente = {"nombre_usuario": user.nombre_usuario, "email": user.email, "password_hash": hashed_password}
    await db.clients.insert_one(nuevo_cliente)
    return {"mensaje": "Usuario registrado exitosamente"}

@router.post("/login")
async def iniciar_sesion(user: UserLogin):
    db_user = await db.clients.find_one({"email": user.email})
    if not db_user or not pwd_context.verify(user.password, db_user["password_hash"]):
        raise HTTPException(status_code=401, detail="Correo o contraseña incorrectos")
    token = crear_token(user.email)
    return {"access_token": token, "token_type": "bearer", "usuario": db_user["nombre_usuario"]}