const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const { ApolloServer, gql } = require('apollo-server-express');

// Conexión a MongoDB
mongoose.connect('mongodb://localhost:27017/bdunab2');

const Usuario = require('./Models/Usuarios');

// Definición de la estructura de GraphQL (Tu avance)
const typeDefs = gql`
    type Usuario {
        id: ID!
        nombre: String!
        pass: String!
    }

    input UsuarioInput {
        nombre: String!
        pass: String!
    }

    type Alert {
        message: String
    }

    type Query {
        getUsuarios: [Usuario]
        getUsuariosById(id: ID!): Usuario
    }

    type Mutation {
        addUsuario(input: UsuarioInput): Usuario
        updUsuario(id: ID!, input: UsuarioInput): Usuario
        delUsuario(id: ID!): Alert
    }
`;


const resolvers = {
    Query: {
        async getUsuarios(obj) {
            const usuarios = await Usuario.find();
            return usuarios;
            
        },
        async getUsuariosById (obj,{id}){
            const usuariosBus = await Usuario.findById(id);
            if (usuariosBus == null){
                return null;
            } else {
                return usuariosBus;
            }
        }
    },
    
    Mutation: {
        async addUsuario(obj, {input}){
            const usuario = new Usuario(input);
            await usuario.save();
            return usuario;
        },
        async updUsuario(obj, {id,input}){
            const usuario = await usuario.findByIdAndUpdate(id, input);
            return usuario;
        },
        async delUsuario (obj, {id}){
            await Usuario.deleteOne({_id: id});
            return {
                message: "Usuario borrado" 
            }
        }
        
    }
};


let apolloServer = null;
const corsOption = {
    origin: "http://localhost:8090",
    credentials: false
};
async function startServer() {
    apolloServer = new ApolloServer({typeDefs, resolvers, corsOption});
    await apolloServer.start();
    apolloServer.applyMiddleware({app, cors: false});
    
}

startServer ();

const app = express();
app.use(cors());
app.listen(8090, function(){
    console.log("Graphql iniciado");
});

