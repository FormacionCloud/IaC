// Librería express
import express from "express";

const app = express();

// GET /
app.get("/", (req, res) => {
  let mensaje = `Hola mundo!! El parámetro 'nombre' es: ${req.query.nombre}`;

  // TODO 1: descomentar el siguiente código para introducir un cambio
  // mensaje = `Hola mundo!! Esta es la versión 2!! El parámetro 'nombre' es: ${req.query.nombre}`;
  res.send(mensaje);
});

// GET /adios
// TODO 2: Eliminar este código para que no exista la ruta y se genera un error
app.get("/adios", (req, res) => {
  res.send("Adiós mundo!!");
});
// END TODO 2

// Funciones auxiliares para testear en local
function startServer() {
  console.log("Servidor escuchando en puerto 3000");
  return app.listen(3000);
}

function stopServer(server) {
  return new Promise((resolve) => {
    server.close(() => {
      resolve();
    });
  });
}

export { app, startServer, stopServer };
