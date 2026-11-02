import stomp
import argparse
import json

def enviar_mensaje():
    # Configuramos los argumentos de la consola
    parser = argparse.add_argument_group('Parámetros del mensaje')
    parser = argparse.ArgumentParser(description='Productor de mensajes STOMP para pedidos.')
    parser.add_argument('--host', default='localhost', help='Host del broker')
    parser.add_argument('--puerto', type=int, default=61613, help='Puerto STOMP')
    parser.add_argument('--user', default='admin', help='Usuario del broker')
    parser.add_argument('--password', default='admin', help='Contraseña del broker')
    parser.add_argument('--formato', choices=['texto', 'fijo', 'xml', 'json'], default='json', help='Formato del mensaje')
    parser.add_argument('--id', required=True, help='ID del pedido')
    parser.add_argument('--cliente', required=True, help='Nombre del cliente')
    parser.add_argument('--monto', required=True, help='Monto del pedido')
    
    args = parser.parse_args()

    # Validación del monto con try/except como pidió el profe
    try:
        monto_validado = float(args.monto)
        if monto_validado < 0:
            raise ValueError("El monto no puede ser negativo.")
    except ValueError:
        print("Error: El monto ingresado debe ser un número válido.")
        return

    # Armamos el cuerpo del mensaje según el formato elegido
    cuerpo = ""
    content_type = "text/plain"

    if args.formato == 'json':
        datos = {"id": args.id, "cliente": args.cliente, "monto": monto_validado}
        cuerpo = json.dumps(datos)
        content_type = "application/json"
    
    elif args.formato == 'xml':
        cuerpo = f"<pedido><id>{args.id}</id><cliente>{args.cliente}</cliente><monto>{monto_validado}</monto></pedido>"
        content_type = "application/xml"
        
    elif args.formato == 'texto':
        cuerpo = f"ID:{args.id}, Cliente:{args.cliente}, Monto:{monto_validado}"
        content_type = "text/plain"
        
    elif args.formato == 'fijo':
        # Ancho fijo: ID (5), Cliente (20), Monto (10)
        cuerpo = f"{args.id:<5}{args.cliente:<20}{monto_validado:<10.2f}"
        content_type = "text/plain"

    # Conexión al broker
    try:
        conn = stomp.Connection([(args.host, args.puerto)])
        conn.connect(args.user, args.password, wait=True)
        
        # Enviamos el mensaje a la cola con los headers correspondientes
        destino = '/queue/pedidos'
        cabeceras = {'content-type': content_type}
        
        conn.send(body=cuerpo, destination=destino, headers=cabeceras)
        print(f"Mensaje enviado con éxito a {destino} en formato {args.formato}.")
        
        # Desconexión limpia
        conn.disconnect()
        print("Desconectado del broker.")
        
    except Exception as e:
        print(f"Error al conectar o enviar el mensaje: {e}")

if __name__ == '__main__':
    enviar_mensaje()