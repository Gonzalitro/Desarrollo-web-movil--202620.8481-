// 1. Inicializamos el carrito como un arreglo vacío
let carrito = [];

// 2. Esperamos a que la página HTML cargue completamente
document.addEventListener("DOMContentLoaded", function () {
    
    // Buscamos todos los botones que tienen la clase de agregar al carrito ("+")
    const botonesAgregar = document.querySelectorAll('.producto-carrito-btn');

    // A cada botón le agregamos un "escuchador" de clics
    botonesAgregar.forEach(function (boton) {
        boton.addEventListener('click', agregarAlCarrito);
    });

    // Actualizamos el carrito al inicio para que muestre "Carrito (0)"
    actualizarCarrito();
});

// 3. Función que se ejecuta cuando el usuario hace clic en un botón "+"
function agregarAlCarrito(evento) {
    // Obtenemos el botón específico al que se le hizo clic
    const boton = evento.target;

    // Buscamos la tarjeta (card) completa que envuelve a este botón
    const card = boton.closest('.producto-card');

    // Extraemos el texto del título (Por ejemplo: "Sandwich Umami: 6.500")
    const tituloTexto = card.querySelector('h5').innerText;

    // Separamos el nombre del precio usando los dos puntos ":"
    const partes = tituloTexto.split(':');
    const nombreProducto = partes[0].trim(); // Obtiene "Sandwich Umami"
    
    // Obtenemos el precio, le quitamos los puntos (si los tiene) y lo convertimos a número
    const precioString = partes[1].trim().replace(/\./g, ''); // Obtiene "6500"
    const precioProducto = parseInt(precioString);

    // Revisamos si el producto ya existe en el carrito
    const productoExistente = carrito.find(item => item.nombre === nombreProducto);

    if (productoExistente) {
        // Si ya está en el carrito, solo aumentamos la cantidad
        productoExistente.cantidad++;
    } else {
        // Si no está, lo agregamos como un producto nuevo
        carrito.push({
            nombre: nombreProducto,
            precio: precioProducto,
            cantidad: 1
        });
    }

    // Finalmente, recalculamos los totales y actualizamos el HTML
    actualizarCarrito();
    
    // Opcional: Pequeña alerta visual o en consola para saber que funcionó
    console.log(`Agregaste 1 ${nombreProducto} al carrito.`);
}

// 4. Función para actualizar la vista del carrito (La que corregimos antes)
function actualizarCarrito() {
    var btnNav = document.getElementById("btn-carrito-nav");
    var lista = document.getElementById("carrito-lista");
    var totalEl = document.getElementById("carrito-total");

    var totalItems = 0;
    var totalPagar = 0;

    // Sumamos las cantidades y el dinero total
    carrito.forEach(function (item) {
        totalItems += item.cantidad;
        totalPagar += (item.precio * item.cantidad);
    });

    // Actualizar botón de navegación
    if (btnNav) {
        btnNav.innerHTML = `<i class="bi bi-cart3" style="font-size: 1.2rem;"></i> Carrito (${totalItems})`;
    }

    // Actualizar texto del Total a Pagar en el modal
    if (totalEl) {
        totalEl.innerText = "$" + totalPagar.toLocaleString("es-CL");
    }

    // Actualizar la lista de productos dentro del modal
    if (lista) {
        if (carrito.length === 0) {
            lista.innerHTML = `
                <div class="text-center p-3">
                    <p style="color: #b0b0b0;">Tu carrito está vacío.</p>
                </div>
            `;
            return;
        }

        var html = '';
        carrito.forEach(function (item) {
            var subtotal = item.precio * item.cantidad;
            html += `
                <div class="d-flex justify-content-between align-items-center mb-3" style="background-color: #2a2a2a; padding: 10px; border-radius: 8px;">
                    <div>
                        <strong style="color: #fff;">${item.nombre}</strong><br>
                        <small style="color: #b0b0b0;">$${item.precio.toLocaleString("es-CL")} c/u</small>
                    </div>
                    <div class="text-end">
                        <span style="color: #fff; font-size: 0.9rem;">Cant: ${item.cantidad}</span><br>
                        <strong style="color: #accent; font-size: 1.1rem;">$${subtotal.toLocaleString("es-CL")}</strong>
                    </div>
                </div>
            `;
        });

        lista.innerHTML = html;
    }
}