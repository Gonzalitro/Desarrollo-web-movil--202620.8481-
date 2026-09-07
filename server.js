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

// Lógica de las consultas (Para tu compañero)
const resolvers = {
    Query: {
        // Tu compañero programará getUsuarios y getUsuariosById aquí
    },
    Mutation: {
        // Tu compañero programará addUsuario, updUsuario y delUsuario aquí
    }
};

// Inicialización del servidor (Para tu compañero)