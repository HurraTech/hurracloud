"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _axios = require("axios");

var _axios2 = _interopRequireDefault(_axios);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _asyncToGenerator(fn) { return function () { var gen = fn.apply(this, arguments); return new Promise(function (resolve, reject) { function step(key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { return Promise.resolve(value).then(function (value) { step("next", value); }, function (err) { step("throw", err); }); } } return step("next"); }); }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var HurraUtils = function () {
  function HurraUtils() {
    _classCallCheck(this, HurraUtils);
  }

  _createClass(HurraUtils, null, [{
    key: "getState",
    value: function getState() {
      console.log(process.env.REACT_APP_AUID);
      var auid = process.env.REACT_APP_AUID;
      return new Promise(function (resolve, reject) {
        _axios2.default.get("http://192.168.1.2:5000/apps/" + auid).then(function (res) {
          resolve(res.data.state);
        });
      });
    }
  }, {
    key: "setState",
    value: function setState(state) {
      var auid = process.env.REACT_APP_AUID;
      return new Promise(function (resolve, reject) {
        _axios2.default.put("http://192.168.1.2:5000/apps/" + auid, {
          app: {
            state: state
          }
        }).then(function (res) {
          resolve(res.data.state);
        });
      });
    }
  }, {
    key: "exec",
    value: function exec(container, command) {
      var env = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : {};

      var auid = process.env.REACT_APP_AUID;
      return new Promise(function (resolve, reject) {
        _axios2.default.post("http://192.168.1.2:5000/apps/" + auid + "/" + container + "/_exec", {
          cmd: command,
          env: env
        }).then(function (res) {
          resolve(res.data);
        });
      });
    }
  }, {
    key: "exec_block",
    value: function exec_block(container, command) {
      var env = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : {};

      var auid = process.env.REACT_APP_AUID;
      return new Promise(function (resolve, reject) {
        _axios2.default.post("http://192.168.1.2:5000/apps/" + auid + "/" + container + "/_exec", {
          cmd: command,
          env: env
        }).then(function (res) {
          HurraUtils.wait_for_cmd(res.data.command, resolve);
        });
      });
    }
  }, {
    key: "wait_for_cmd",
    value: function wait_for_cmd(command, resolver) {
      HurraUtils.get_command(command.id).then(function (command_update) {
        if (command_update.status == "completed") resolver(command_update);else {
          setTimeout(function () {
            HurraUtils.wait_for_cmd(command, resolver);
          }, 1000);
        }
      });
    }
  }, {
    key: "get_command",
    value: function get_command(cmd_id) {
      var auid = process.env.REACT_APP_AUID;
      return new Promise(function (resolve, reject) {
        _axios2.default.get("http://192.168.1.2:5000/apps/" + auid + "/app_commands/" + cmd_id).then(function (statusRes) {
          console.log("Command Status", statusRes.data.status);
          resolve(statusRes.data);
        });
      });
    }
  }, {
    key: "callApi",
    value: function () {
      var _ref = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee() {
        var response, body;
        return regeneratorRuntime.wrap(function _callee$(_context) {
          while (1) {
            switch (_context.prev = _context.next) {
              case 0:
                _context.next = 2;
                return fetch('/api/hello');

              case 2:
                response = _context.sent;
                _context.next = 5;
                return response.json();

              case 5:
                body = _context.sent;

                if (!(response.status !== 200)) {
                  _context.next = 8;
                  break;
                }

                throw Error(body.message);

              case 8:
                return _context.abrupt("return", body);

              case 9:
              case "end":
                return _context.stop();
            }
          }
        }, _callee, this);
      }));

      function callApi() {
        return _ref.apply(this, arguments);
      }

      return callApi;
    }()
  }]);

  return HurraUtils;
}();

exports.default = HurraUtils;