import stomp
import time

# Clase para escuchar los mensajes que llegan
class EscuchadorPedidos(stomp.ConnectionListener):
    def on_error(self, frame):
        print(f"[ERROR] Se recibió un error: {frame.body}")

    def on_message(self, frame):
        print("\n--- Nuevo Mensaje Recibido ---")
        headers = frame.headers
        print(f"Tipo de contenido: {headers.get('content-type', 'No especificado')}")
        print(f"Cuerpo del mensaje:\n{frame.body}")
        print("------------------------------\n")

def iniciar_consumidor():
    host = 'localhost'
    puerto = 61613
    usuario = 'admin'
    password = 'admin'
    destino = '/queue/pedidos'

    # Configuramos la conexión
    conn = stomp.Connection([(host, puerto)])
    
    # Asignamos el listener
    conn.set_listener('', EscuchadorPedidos())
    
    try:
        conn.connect(usuario, password, wait=True)
        # Nos suscribimos a la cola
        conn.subscribe(destination=destino, id=1, ack='auto')
        print(f"Consumidor conectado y escuchando en {destino}...")
        
        # Mantenemos el script corriendo para que escuche infinitamente
        while True:
            time.sleep(2)
            
    except KeyboardInterrupt:
        print("\nDeteniendo el consumidor...")
        conn.disconnect()
    except Exception as e:
        print(f"Error en la conexión del consumidor: {e}")

if __name__ == '__main__':
    iniciar_consumidor()