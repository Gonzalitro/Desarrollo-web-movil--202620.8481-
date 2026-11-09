
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

    views {
        systemContext mrSandwich "C1_Contexto" "Contexto general del proyecto Mr. Sandwich." {
            title "C1 - Contexto de Mr. Sandwich"
            include *
            autoLayout lr
        }

        container mrSandwich "C2_Contenedores" "Frontend, backend FastAPI y base de datos MongoDB." {
            title "C2 - Contenedores de Mr. Sandwich"
            include *
            autoLayout lr
        }

        component mrSandwich.frontend "C3_Frontend" "Estructura interna del frontend estático." {
            title "C3 - Componentes del Frontend"
            include *
            autoLayout lr
        }

        component mrSandwich.backend "C3_Backend" "Routers REST, montaje GraphQL y documentación de la única aplicación FastAPI." {
            title "C3 - Componentes del Backend FastAPI"
            include *
            autoLayout lr
        }

        dynamic mrSandwich "D01_Carrito_Frontend" "Comportamiento local del catálogo y carrito en Carta.html y app.js. No interviene el backend." {
            title "D01 - Navegación de carta y carrito local"
            1: visitante -> mrSandwich.frontend.homePage "Abre la página principal index.html"
            2: visitante -> mrSandwich.frontend.menuPage "Navega a Carta.html y selecciona un producto mediante el botón +"
            4: mrSandwich.frontend.menuPage -> mrSandwich.frontend.cartLogic "Dispara el evento de agregar producto"
            5: mrSandwich.frontend.cartLogic -> mrSandwich.frontend.menuPage "Actualiza contador, cantidades y total del modal"
            autoLayout lr
        }

        dynamic mrSandwich "D02_Consulta_Inventario_API" "Consulta de inventario ejecutada directamente contra el backend, por ejemplo desde Swagger. No representa una llamada del frontend." {
            title "D02 - Consulta REST del catálogo"
            1: desarrollador -> mrSandwich.backend.swaggerDocs "Abre Swagger UI en /docs"
            2: desarrollador -> mrSandwich.backend.inventoryRouter "Ejecuta GET /api/inventory/productos"
            3: mrSandwich.backend.inventoryRouter -> mrSandwich.mongo "Consulta la colección inventory; inserta productos iniciales si está vacía"
            4: mrSandwich.mongo -> mrSandwich.backend.inventoryRouter "Devuelve los documentos del catálogo"
            5: mrSandwich.backend.inventoryRouter -> desarrollador "Devuelve la respuesta HTTP del endpoint"
            autoLayout lr
        }

        dynamic mrSandwich "D03_Registro_Login" "Registro e inicio de sesión implementados en el router de clientes." {
            title "D03 - Registro e inicio de sesión de cliente"
            1: desarrollador -> mrSandwich.backend.clientsRouter "Envía POST /api/clients/register con nombre, correo y contraseña"
            2: mrSandwich.backend.clientsRouter -> mrSandwich.mongo "Guarda el cliente en clients con contraseña hasheada mediante bcrypt"
            3: mrSandwich.mongo -> mrSandwich.backend.clientsRouter "Confirma el resultado de persistencia"
            4: desarrollador -> mrSandwich.backend.clientsRouter "Envía POST /api/clients/login con correo y contraseña"
            5: mrSandwich.backend.clientsRouter -> mrSandwich.mongo "Busca el cliente para verificar las credenciales"
            6: mrSandwich.mongo -> mrSandwich.backend.clientsRouter "Devuelve el registro del cliente"
            7: mrSandwich.backend.clientsRouter -> desarrollador "Responde con access_token JWT y tipo bearer cuando la autenticación es válida"
            autoLayout lr
        }

        dynamic mrSandwich "D04_Creacion_Pedido" "Creación de pedido protegida por JWT, mediante el endpoint REST del router orders." {
            title "D04 - Creación de pedido con JWT"
            1: desarrollador -> mrSandwich.backend.ordersRouter "Envía POST /api/orders/crear con Authorization: Bearer y el detalle del pedido; la ruta valida el JWT"
            2: mrSandwich.backend.ordersRouter -> mrSandwich.mongo "Inserta pedido con email_cliente, items, total y estado pendiente"
            3: mrSandwich.mongo -> mrSandwich.backend.ordersRouter "Devuelve el documento o identificador creado"
            4: mrSandwich.backend.ordersRouter -> desarrollador "Responde con el resultado de creación y pedido_id"
            autoLayout lr
        }

        dynamic mrSandwich "D05_Procesar_Pago" "Registro de pago simulado y actualización del estado del pedido mediante el router payments." {
            title "D05 - Procesamiento de pago simulado"
            1: desarrollador -> mrSandwich.backend.paymentsRouter "Envía POST /api/payments/procesar con pedido_id y monto_total"
            2: mrSandwich.backend.paymentsRouter -> mrSandwich.mongo "Inserta el registro de pago en payments"
            3: mrSandwich.backend.paymentsRouter -> mrSandwich.mongo "Actualiza el pedido asociado en orders a estado pagado"
            4: mrSandwich.mongo -> mrSandwich.backend.paymentsRouter "Confirma las operaciones de persistencia"
            5: mrSandwich.backend.paymentsRouter -> desarrollador "Devuelve el resultado del procesamiento"
            autoLayout lr
        }

        dynamic mrSandwich "D06_Consulta_GraphQL" "Consulta de detalle de pedido mediante Strawberry GraphQL, leyendo directamente las colecciones orders y clients." {
            title "D06 - Consulta GraphQL del detalle de pedido"
            1: desarrollador -> mrSandwich.backend.graphqlEndpoint "Abre /graphql y ejecuta ver_detalle_pedido(pedido_id)"
            2: mrSandwich.backend.graphqlEndpoint -> mrSandwich.mongo "Busca el pedido en la colección orders"
            3: mrSandwich.mongo -> mrSandwich.backend.graphqlEndpoint "Devuelve los datos del pedido"
            4: mrSandwich.backend.graphqlEndpoint -> mrSandwich.mongo "Busca los datos del cliente en clients"
            5: mrSandwich.mongo -> mrSandwich.backend.graphqlEndpoint "Devuelve los datos del cliente"
            6: mrSandwich.backend.graphqlEndpoint -> desarrollador "Compone PedidoGQL con cliente_info y devuelve la respuesta GraphQL"
            autoLayout lr
        }

        deployment mrSandwich entornoLocal "D_DesarrolloLocal" "Despliegue local de navegador, proceso FastAPI y MongoDB." {
            title "Despliegue - Desarrollo local de Mr. Sandwich"
            include *
            autoLayout lr
        }

        styles {
            element "Person" {
                shape person
                background #54718A
                color #FFFFFF
            }
            element "Actor" {
                shape person
                background #54718A
                color #FFFFFF
            }
            element "ActorTecnico" {
                shape person
                background #6A7180
                color #FFFFFF
            }
            element "Software System" {
                background #173B5D
                color #FFFFFF
            }
            element "SistemaEvaluado" {
                background #173B5D
                color #FFFFFF
            }
            element "Container" {
                shape roundedbox
                background #E4EDF5
                color #173B5D
            }
            element "Frontend" {
                shape webbrowser
                background #D6EAF8
                color #153E5B
            }
            element "Backend" {
                background #DCE9E2
                color #234C39
            }
            element "BaseDatos" {
                shape cylinder
                background #E8E5F0
                color #40385F
            }
            element "Component" {
                shape roundedbox
                background #F0F4F7
                color #263F54
            }
            element "Presentacion" {
                background #D8EAF7
                color #174260
            }
            element "LogicaFrontend" {
                background #E6E1F2
                color #453A64
            }
            element "Composicion" {
                background #DDE8E1
                color #244C39
            }
            element "ModuloREST" {
                background #DFEAF2
                color #21445E
            }
            element "ModuloGraphQL" {
                background #E8E1F1
                color #493A68
            }
            element "HerramientaPruebas" {
                background #F5EBD8
                color #604A20
            }
            element "SistemaExterno" {
                background #F3EEE6
                color #5C4B32
                stroke #A99A82
            }
            element "Deployment Node" {
                background #EDF1F5
                color #253D52
                stroke #A1B1BF
            }
            relationship "Relationship" {
                color #60758A
                thickness 2
            }
        }
    }
}