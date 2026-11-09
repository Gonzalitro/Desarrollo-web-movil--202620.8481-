
workspace "Mr. Sandwich" "Modelo C4 de la plataforma web y backend de Mr. Sandwich, basado en los archivos frontend y backend revisados." {

    !identifiers hierarchical

    model {
        // Actores reales del alcance revisado.
        visitante = person "Cliente / visitante" "Persona que navega por la página principal y revisa la carta de productos." {
            tags "Actor"
        }

        desarrollador = person "Desarrollador / evaluador" "Persona que ejecuta y prueba los endpoints del backend mediante Swagger y la interfaz GraphQL." {
            tags "ActorTecnico"
        }

        mrSandwich = softwareSystem "Mr. Sandwich" "Sitio web informativo y de carta, junto con una API backend basada en FastAPI y MongoDB." {
            tags "SistemaEvaluado"

            frontend = container "Frontend web estático" "Páginas HTML, estilos CSS y JavaScript ejecutados en el navegador. La carta contiene productos definidos en el HTML y el carrito se calcula en memoria en el navegador." "HTML5, CSS3, JavaScript, Bootstrap 5.3.8" {
                tags "Frontend"

                homePage = component "Página principal (index.html)" "Presenta inicio, carrusel, información de la empresa, ubicación, delivery y modales visuales de cuenta y carrito. Incluye un enlace externo a Uber Eats." "HTML" {
                    tags "Presentacion"
                }

                menuPage = component "Carta de productos (Carta.html)" "Muestra productos estáticos organizados en las secciones Sándwiches, Wraps, Extras y Bebestibles. Cada tarjeta incorpora un botón para agregar al carrito." "HTML" {
                    tags "Presentacion"
                }

                cartLogic = component "Lógica del carrito (app.js)" "Mantiene un arreglo carrito en memoria, agrega productos, incrementa cantidades, calcula subtotales y total, y actualiza el contador y el modal. No utiliza localStorage ni sessionStorage y no realiza llamadas al backend." "JavaScript" {
                    tags "LogicaFrontend"
                }

                styles = component "Estilos visuales (Estilo.css)" "Define los estilos generales y componentes visuales compartidos por las páginas." "CSS" {
                    tags "Presentacion"
                }
            }

            backend = container "Backend API" "Una sola aplicación FastAPI creada en Main.py y ejecutada con Uvicorn. Agrupa los routers REST y el endpoint GraphQL en el mismo proceso; no son microservicios desplegados por separado." "Python, FastAPI, Uvicorn, Motor, Strawberry GraphQL" {
                tags "Backend"

                mainApp = component "Aplicación principal (Main.py)" "Crea la aplicación FastAPI, registra los routers de clientes, inventario, pedidos y pagos, y monta Strawberry GraphQL en /graphql." "FastAPI" {
                    tags "Composicion"
                }

                clientsRouter = component "Router de clientes (clients/rutas.py)" "Implementa POST /api/clients/register y POST /api/clients/login. Registra contraseñas con hash bcrypt y genera tokens JWT HS256 con vigencia configurada de dos horas." "FastAPI APIRouter, bcrypt, JWT" {
                    tags "ModuloREST"
                }

                inventoryRouter = component "Router de inventario (inventory/rutas.py)" "Implementa GET /api/inventory/productos. Consulta el catálogo y agrega productos iniciales cuando la colección de inventario está vacía. No implementa una ruta POST para crear productos." "FastAPI APIRouter" {
                    tags "ModuloREST"
                }

                ordersRouter = component "Router de pedidos (orders/rutas.py)" "Implementa POST /api/orders/crear. Requiere un token Bearer JWT y persiste el correo del cliente, los artículos, el total y el estado inicial pendiente." "FastAPI APIRouter, OAuth2PasswordBearer, JWT" {
                    tags "ModuloREST"
                }

                paymentsRouter = component "Router de pagos (payments/rutas.py)" "Implementa POST /api/payments/procesar. Registra el pago y actualiza el pedido asociado a pagado. La ruta actual no exige autenticación JWT ni se conecta a un proveedor de pagos real." "FastAPI APIRouter" {
                    tags "ModuloREST"
                }

                graphqlEndpoint = component "Endpoint GraphQL (/graphql)" "Monta Strawberry GraphQL dentro de la misma aplicación FastAPI. La consulta ver_detalle_pedido obtiene información del pedido y del cliente directamente desde MongoDB; no requiere autenticación en el código revisado." "Strawberry GraphQL" {
                    tags "ModuloGraphQL"
                }

                swaggerDocs = component "Documentación Swagger (/docs)" "Interfaz OpenAPI generada por FastAPI para consultar y ejecutar las rutas REST durante el desarrollo y las pruebas." "OpenAPI, Swagger UI" {
                    tags "HerramientaPruebas"
                }
            }

            mongo = container "Base de datos mr_sandwich_db" "Una única base de datos MongoDB local. Contiene las colecciones clients, inventory, orders y payments; no se modelan bases separadas por router." "MongoDB" {
                tags "BaseDatos"
            }
        }

        // Dependencias externas realmente referenciadas desde el frontend.
        webAssets = softwareSystem "CDN y fuentes web" "Recursos externos usados por las páginas: Bootstrap y Bootstrap Icons desde jsDelivr, y fuente Poppins desde Google Fonts." {
            tags "SistemaExterno"
        }

        uberEats = softwareSystem "Uber Eats" "Sitio externo al que apunta el enlace de delivery de la página principal. No existe una integración API implementada en el frontend revisado." {
            tags "SistemaExterno"
        }

        // Relaciones de uso del frontend.
        visitante -> mrSandwich.frontend "Navega por la página principal y consulta la carta" "Navegador web"
        visitante -> mrSandwich.frontend.homePage "Abre la página principal"
        visitante -> mrSandwich.frontend.menuPage "Consulta la carta y selecciona productos"
        mrSandwich.frontend.homePage -> mrSandwich.frontend.menuPage "Abre Carta.html desde los enlaces de navegación y compra"
        mrSandwich.frontend.menuPage -> mrSandwich.frontend.homePage "Regresa a index.html desde la navegación"
        mrSandwich.frontend.homePage -> mrSandwich.frontend.styles "Carga Estilo.css"
        mrSandwich.frontend.menuPage -> mrSandwich.frontend.styles "Carga Estilo.css"
        mrSandwich.frontend.homePage -> mrSandwich.frontend.cartLogic "Carga app.js; inicializa el contador del carrito"
        mrSandwich.frontend.menuPage -> mrSandwich.frontend.cartLogic "Carga app.js y registra los botones de agregar al carrito"
        mrSandwich.frontend.cartLogic -> mrSandwich.frontend.menuPage "Actualiza el contador, la lista y el total del carrito en el DOM"
        mrSandwich.frontend.homePage -> webAssets "Descarga Bootstrap, Bootstrap Icons y fuente Poppins" "HTTPS"
        mrSandwich.frontend.menuPage -> webAssets "Descarga Bootstrap, Bootstrap Icons y fuente Poppins" "HTTPS"
        mrSandwich.frontend.homePage -> uberEats "Abre el sitio externo desde el enlace Pedir por Uber Eats" "HTTPS / navegación web"

        // El desarrollador prueba el backend directamente con las herramientas expuestas por FastAPI.
        desarrollador -> mrSandwich.backend "Ejecuta y prueba la API local" "HTTP en localhost"
        desarrollador -> mrSandwich.backend.swaggerDocs "Consulta y ejecuta operaciones REST en /docs" "Navegador web"
        desarrollador -> mrSandwich.backend.graphqlEndpoint "Ejecuta consultas GraphQL en /graphql" "Navegador web"
        desarrollador -> mrSandwich.backend.clientsRouter "Prueba registro e inicio de sesión"
        desarrollador -> mrSandwich.backend.inventoryRouter "Prueba consulta de productos"
        desarrollador -> mrSandwich.backend.ordersRouter "Prueba creación de pedidos autenticada"
        desarrollador -> mrSandwich.backend.paymentsRouter "Prueba procesamiento de pagos"
        mrSandwich.backend.clientsRouter -> desarrollador "Devuelve resultado de registro o token JWT"
        mrSandwich.backend.inventoryRouter -> desarrollador "Devuelve catálogo o respuesta HTTP"
        mrSandwich.backend.ordersRouter -> desarrollador "Devuelve identificador y resultado del pedido"
        mrSandwich.backend.paymentsRouter -> desarrollador "Devuelve resultado del procesamiento del pago"
        mrSandwich.backend.graphqlEndpoint -> desarrollador "Devuelve datos y errores de la consulta GraphQL"

        // Composición de la única aplicación FastAPI.
        mrSandwich.backend.mainApp -> mrSandwich.backend.clientsRouter "Registra router de clientes"
        mrSandwich.backend.mainApp -> mrSandwich.backend.inventoryRouter "Registra router de inventario"
        mrSandwich.backend.mainApp -> mrSandwich.backend.ordersRouter "Registra router de pedidos"
        mrSandwich.backend.mainApp -> mrSandwich.backend.paymentsRouter "Registra router de pagos"
        mrSandwich.backend.mainApp -> mrSandwich.backend.graphqlEndpoint "Monta Strawberry GraphQL en /graphql"
        mrSandwich.backend.mainApp -> mrSandwich.backend.swaggerDocs "Expone documentación OpenAPI en /docs"

        // Acceso real de los módulos a las colecciones de MongoDB.
        mrSandwich.backend.clientsRouter -> mrSandwich.mongo "Lee y escribe documentos de la colección clients" "Motor / MongoDB"
        mrSandwich.mongo -> mrSandwich.backend.clientsRouter "Devuelve los documentos de clientes consultados" "Motor / MongoDB"
        mrSandwich.backend.inventoryRouter -> mrSandwich.mongo "Lee la colección inventory y agrega catálogo inicial si está vacía" "Motor / MongoDB"
        mrSandwich.mongo -> mrSandwich.backend.inventoryRouter "Devuelve los documentos del catálogo" "Motor / MongoDB"
        mrSandwich.backend.ordersRouter -> mrSandwich.mongo "Inserta pedidos en la colección orders" "Motor / MongoDB"
        mrSandwich.mongo -> mrSandwich.backend.ordersRouter "Devuelve el resultado de las operaciones sobre pedidos" "Motor / MongoDB"
        mrSandwich.backend.paymentsRouter -> mrSandwich.mongo "Inserta pagos en payments y actualiza el pedido en orders" "Motor / MongoDB"
        mrSandwich.mongo -> mrSandwich.backend.paymentsRouter "Devuelve el resultado de las operaciones de pago" "Motor / MongoDB"
        mrSandwich.backend.graphqlEndpoint -> mrSandwich.mongo "Consulta directamente orders y clients para resolver ver_detalle_pedido" "Motor / MongoDB"
        mrSandwich.mongo -> mrSandwich.backend.graphqlEndpoint "Devuelve documentos de pedido y cliente para la resolución GraphQL" "Motor / MongoDB"

        // Nota de alcance: el ZIP del frontend no contiene fetch, XMLHttpRequest ni otra llamada a la API.
        // Por ello no se dibuja una relación frontend -> backend como integración implementada.

        // Despliegue local de desarrollo, acorde a la ejecución revisada.
        entornoLocal = deploymentEnvironment "Desarrollo_Local" {
            deploymentNode "Equipo local de desarrollo" "Equipo Windows utilizado para ejecutar y probar el proyecto." "Windows" {
                deploymentNode "Navegador web" "Ejecuta las páginas HTML, CSS y JavaScript del frontend. El mecanismo concreto de servido de los archivos no se especifica en los archivos entregados." "Chrome u otro navegador" {
                    containerInstance mrSandwich.frontend
                }

                deploymentNode "Proceso Python / Uvicorn" "Ejecuta Main.py como una única aplicación FastAPI. El comando utilizado es python -m uvicorn Main:app --reload." "Python / Uvicorn; puerto 8000" {
                    containerInstance mrSandwich.backend
                }

                deploymentNode "Servicio MongoDB local" "Motor de base de datos accesible mediante mongodb://localhost:27017." "MongoDB Server; puerto 27017" {
                    containerInstance mrSandwich.mongo
                }
            }
        }
    }

    