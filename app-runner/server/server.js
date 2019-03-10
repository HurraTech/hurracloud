import express from 'express';
import HurraApp from './HurraApp/app';
import sqlite3 from 'sqlite3';

const db = null; // new sqlite3.Database('/var/hurradb/sqlite3.db');

const server = express();
const port = process.env.PORT || 5000;

server.use(express.json())

let app = new HurraApp(server, db)
app.start()

server.listen(port, () => console.log(`Listening on port ${port}`));
