const mockApiData = {
    status: 200,
    message: "Juegos obtenidos correctamente",
    data: [
        { id: "STM-01", nombre: "Grand Theft Auto V", precio: 15500 },
        { id: "STM-02", nombre: "Elden Ring", precio: 45000 },
        { id: "STM-03", nombre: "Baldur's Gate 3", precio: 45000 },
        { id: "STM-04", nombre: "Cyberpunk 2077", precio: 39900 }
    ]
};

const cargarJuegos = () => {
    const comboBox = document.getElementById("cmbJuegos");

    comboBox.innerHTML = '<option value="">Seleccione una opción...</option>';

    mockApiData.data.forEach((juego) => {
        let opcion = document.createElement("option");

        opcion.setAttribute("value", juego.id);
        opcion.innerText = ${juego.nombre} - $${juego.precio} CLP;

        comboBox.appendChild(opcion);
    });

    console.log("DOM manipulado con éxito: " + mockApiData.message);
};