"use strict";

var _express = _interopRequireDefault(require("express"));

var _app = _interopRequireDefault(require("./HurraApp/app"));

var _sqlite = _interopRequireDefault(require("sqlite3"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var args = process.argv.slice(2);
const db = new _sqlite.default.Database('/var/hurradb/sqlite3.db');
const server = (0, _express.default)();
const port = process.env.PORT || 5000;
server.use(_express.default.json());
let app = new _app.default(server, db);
app.start();

if (args[0] == "init") {
  app.init();
} else {
  server.listen(port, () => console.log(`Listening on port ${port}`));
}