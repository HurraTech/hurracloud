"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;

var _axios = _interopRequireDefault(require("axios"));

var _constants = require("./constants");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

const http = require('http');

class HurraServer {
  static getState() {
    console.log(`GETTING STATE from ${_constants.JAWHAR_API}`);
    let auid = process.env.REACT_APP_AUID;
    return new Promise((resolve, reject) => {
      _axios.default.get(`${_constants.JAWHAR_API}/apps/${auid}`).then(res => {
        console.log("RESULT OF STATE IS", res.data.state);
        resolve(res.data.state);
      });
    });
  }

  static setState(state) {
    console.log("SETTING STATE");
    let auid = process.env.REACT_APP_AUID;
    return new Promise((resolve, reject) => {
      _axios.default.put(`${_constants.JAWHAR_API}/apps/${auid}`, {
        app: {
          state: state
        }
      }).then(res => {
        resolve(res.data.state);
      });
    });
  }

  static patchState(state) {
    let auid = process.env.REACT_APP_AUID;
    return new Promise((resolve, reject) => {
      _axios.default.patch(`${_constants.JAWHAR_API}/apps/${auid}`, {
        app: {
          state: state
        }
      }).then(res => {
        resolve(res.data.state);
      });
    });
  }

  static exec(container, command, env = {}) {
    let auid = process.env.REACT_APP_AUID;
    return new Promise((resolve, reject) => {
      _axios.default.post(`${_constants.JAWHAR_API}/apps/${auid}/${container}/_exec`, {
        cmd: command,
        env: env
      }).then(res => {
        resolve(res.data);
      });
    });
  }

  static restart_container(container) {
    let auid = process.env.REACT_APP_AUID;
    return new Promise((resolve, reject) => {
      _axios.default.get(`${_constants.JAWHAR_API}/apps/${auid}/${container}/_restart`).then(res => {
        resolve(res.data);
      });
    });
  }

  static start_container(container) {
    let auid = process.env.REACT_APP_AUID;
    return new Promise((resolve, reject) => {
      _axios.default.get(`${_constants.JAWHAR_API}/apps/${auid}/${container}/_start`).then(res => {
        resolve(res.data);
      });
    });
  }

  static stop_container(container) {
    let auid = process.env.REACT_APP_AUID;
    return new Promise((resolve, reject) => {
      _axios.default.get(`${_constants.JAWHAR_API}/apps/${auid}/${container}/_stop`).then(res => {
        resolve(res.data);
      });
    });
  }

  static exec_sync(container, command, env = {}) {
    let auid = process.env.REACT_APP_AUID;
    console.log(`EXECUTING COMMAND ${_constants.JAWHAR_API}/apps/${auid}/${container}/_exec`, {
      cmd: command,
      env: env
    });
    return new Promise((resolve, reject) => {
      _axios.default.post(`${_constants.JAWHAR_API}/apps/${auid}/${container}/_exec`, {
        cmd: command,
        env: env
      }).then(res => {
        HurraServer.wait_for_cmd(res.data.command, resolve);
      });
    });
  }

  static wait_for_cmd(command, resolver) {
    HurraServer.get_command(command.id).then(command_update => {
      if (command_update.status == "completed") {
        console.log("Command completed", command_update);
        resolver(command_update);
      } else {
        setTimeout(() => {
          HurraServer.wait_for_cmd(command, resolver);
        }, 1000);
      }
    });
  }

  static get_command(cmd_id) {
    let auid = process.env.REACT_APP_AUID;
    return new Promise((resolve, reject) => {
      _axios.default.get(`${_constants.JAWHAR_API}/apps/${auid}/app_commands/${cmd_id}`).then(statusRes => {
        console.log(`Command ${cmd_id} Status`, statusRes.data.status);
        resolve(statusRes.data);
      });
    });
  }

}

exports.default = HurraServer;

_defineProperty(HurraServer, "service_http_proxy", (proxy_host, proxy_port = 80) => (oreq, ores) => {
  console.log("MAKING PROXY REQ TO", proxy_host, oreq.path, oreq.method);
  const options = {
    // host to forward to
    host: proxy_host,
    // port to forward to
    port: proxy_port,
    // path to forward to
    path: `${oreq.path}.html`,
    // request method
    method: oreq.method,
    // headers to send
    headers: oreq.headers
  };
  const creq = http.request(options, pres => {
    // set encoding
    // pres.setEncoding('utf8');
    // set http status code based on proxied response
    ores.writeHead(pres.statusCode); // wait for data

    pres.on('data', chunk => {
      ores.write(chunk);
    });
    pres.on('close', () => {
      // closed, let's end client request as well
      ores.end();
    });
    pres.on('end', () => {
      // finished, let's finish client request as well
      ores.end();
    });
  }).on('error', e => {
    // we got an error
    console.log(e.message);

    try {
      // attempt to set error message and http status
      ores.writeHead(500);
      ores.write(e.message);
    } catch (e) {// ignore
    }

    ores.end();
  });
  creq.end();
});