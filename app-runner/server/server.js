import express from 'express';
import HurraApp from './HurraApp/app';
import sqlite3 from 'sqlite3';

var args = process.argv.slice(2);

const db = new sqlite3.Database('/home/node/db/sqlite3.db');

const server = express();
const port = process.env.PORT || 5000;

server.use(express.json())

let app = new HurraApp(server, db)
app.start()

if (args[0] == "init") {
  app.init();
} else {
  server.listen(port, () => console.log(`Listening on port ${port}`));
}
