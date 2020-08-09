import HurraServer from '../HurraServer'
var fs = require('fs');

class HurraApp {

    constructor(server, db) {
        this.server = server
        this.db = db
    }

    init() {

    }

    start() {
        this.setupRoutes()
    }

    async sendSafeState(res) {
        var state = await HurraServer.getState()
        res.send({status: state.status || "uninitialized", users: state.users || {} })
    }


    setupRoutes() {
        this.server.get('/*', HurraServer.service_http_proxy('syncthing', 8384))
    }

    sanitize_client_name(name) {
        return name.replace(/[^a-z0-9]/gi, '_').toLowerCase();
    }

}

module.exports = HurraApp;
