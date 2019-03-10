import express from 'express';
import HurraApp from './HurraApp/app';
const server = express();
const port = process.env.PORT || 5000;

server.use(express.json())

let app = new HurraApp(server)
app.start()

server.listen(port, () => console.log(`Listening on port ${port}`));
