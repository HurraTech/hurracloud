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

    async updateClientsList(state) {
        if (typeof state === 'undefined') {
            state = await HurraServer.getState()
        }

        return new Promise((resolve,reject) => {
            console.log("Refreshing clients list")
            HurraServer.exec_sync("pki", "ovpn_listclients").then(async (command) => {
                var clients = command.output.split("\n")
                clients.shift() // first element is just header
                clients.forEach(client => {                                        
                    var [client_key, created, expires, status] = client.split(",")                    
                    if (client_key.trim() == "") return
                    if (client_key in state.users) {
                        console.log(`Found ${client_key}`)
                        state.users[client_key]["created"] = created
                        state.users[client_key]["expires"] = expires
                        state.users[client_key]["status"] = status
                    } else {
                        console.log(`Found ${client_key}, but was not found in our state?`)
                        // WARNING: User seem to be added outside of UI. 
                        // TODO: security alert or something
                    }
                });
                console.log(`Updated state:`, state)
                await HurraServer.patchState({ users: state.users})
                resolve(state)
            })
        })
    }

    setupRoutes() {
        this.server.get('/reset', (req, res) => {
            console.log("Goingt to reset")
            HurraServer.exec_sync("pki", "rm -rf /etc/openvpn/*", {}).then(async (command) => {
                await HurraServer.stop_container("server")
                HurraServer.setState({status: "uninitialized"}).then(state => {
                    res.send({done: true})
                  })
              })
        });

        this.server.get('/state', async (req, res) => {            
            this.sendSafeState(res);
        })

        this.server.get('/refresh', async (req, res) => {            
            await this.updateClientsList()
            this.sendSafeState(res)
        })

        this.server.delete('/users/:client_key', async (req,res) => {
            var client_filename = req.params.client_key
            console.log("Executing", `revoke_user ${client_filename}`)
            console.log("Request Body", req.body)
            console.log("ENV",  { "CA_PASS": req.body.password })
            await HurraServer.patchState({status: `removing_${client_filename}`})
            HurraServer.exec_sync("pki", `revoke_user ${client_filename}`, { "CA_PASS": req.body.password }).then(async (command) => {
                var result = command.output.trim()
                var result = command.output.trim()
                console.log(`Result is '${result}'`)
                await HurraServer.patchState({status: "ok"})
                switch (result) {
                    case "ERROR":
                        res.send({error: `Failed to delete '${client_filename}'. Make sure you entered correct Master Password`})
                        break;
                    case "SUCCESS":
                        await this.updateClientsList()
                        this.sendSafeState(res)
                        break;
                }

            })
        })

        this.server.post('/user', async (req,res) => {
            let client_filename = this.sanitize_client_name(req.body.name);
            let client_name = req.body.name
            let state = await HurraServer.getState()
            console.log("Executing", `create_new_user ${client_filename}`)
            console.log("ENV",  { "CA_PASS": req.body.password })
            await HurraServer.patchState({status: "adding_user"})
            HurraServer.exec_sync("pki", `create_new_user ${client_filename}`, { "CA_PASS": req.body.password }).then(async (command) => {
                var result = command.output.trim()
                await HurraServer.patchState({status: "ok"})
                console.log(`Result is '${result}'`)
                switch (result) {
                    case "ERROR:1":
                        res.send({error: `User name "${client_filename}" is already used`})
                        break;
                    case "ERROR:2":
                        res.send({error: `Failed to add user. Make sure you entered correct Master Password`})
                        break;
                    case "SUCCESS":
                        if (!state.users) state.users = {}
                        state.users[client_filename] = { client_name: client_name };
                        console.log("Success. Updating our clients list")
                        await this.updateClientsList(state)
                        this.sendSafeState(res)
                        break;
                    case "ERROR:3":
                    default:
                        res.send({error: `There was an unexpected error while creating user, please try again`})
                        break;
                }
            })
        })
        
        this.server.post('/setup', async (req, res) => {
            await HurraServer.setState({status: "initializing"})
            HurraServer.exec_sync("pki", "setup_vpn_server", {}).then((command) => {
                HurraServer.exec_sync("pki", "ovpn_initpki",
                    {
                        "EASYRSA_BATCH": 1,
                        "EASYRSA_REQ_CN": "HurraVPN",
                        "CA_PASS": req.body.password,
                    }).then(async () => {
                        console.log("Done!")
                        await HurraServer.start_container("server")
                        HurraServer.setState({status: "ok"}).then(() => {
                            res.send({done: true})
                        })
                    })
                })
        })

        this.server.get('/users/:client_key/ovpn', async (req, res) => { 
            HurraServer.exec_sync("pki", `gen_client_ovpn ${req.params.client_key}`, {}).then((command) => {
                res.set({"Content-Disposition":`attachment; filename=${req.params.client_key}.ovpn`});
                res.send(command.output)
            })
        })

    }

    sanitize_client_name(name) {
        return name.replace(/[^a-z0-9]/gi, '_').toLowerCase();
    }

}

module.exports = HurraApp;
