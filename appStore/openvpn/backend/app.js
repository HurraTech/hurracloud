import HurraServer from '../HurraServer'

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

    sendSafeState(res, state) {
        res.send({status: state.status || "uninitialized", users: state.users || {} })
    }

    setupRoutes() {
        this.server.get('/reset', (req, res) => {
            console.log("Goingt to reset")
            HurraServer.exec_block("pki", "rm -rf /etc/openvpn/*", {}).then((command) => {
                HurraServer.setState({status: "uninitialized"}).then(state => {
                    res.send({done: true})
                  })
              })
        });

        this.server.get('/state', async (req, res) => {
            let state = await HurraServer.getState()
            this.sendSafeState(res, state);
        })

        this.server.post('/user', async (req,res) => {
            let client_filename = this.sanitize_client_name(req.body.name);
            let client_name = req.body.name
            let state = await HurraServer.getState()
            console.log("Executing", `easyrsa build-client-full ${client_filename}`)
            console.log("ENV",  { "CA_PASS": req.body.password })
            await HurraServer.setState({status: "adding_removing_user"})
            HurraServer.exec_block("pki", `easyrsa build-client-full ${client_filename} nopass`, { "CA_PASS": req.body.password }).then(async (command) => {
                if (!state.users) state.users = {}
                state.users[client_filename] = client_name;
                state.status = "initialized"
                await HurraServer.setState(state)
                this.sendSafeState(res, state);
            })
        })
        
        this.server.post('/setup', async (req, res) => {
            await HurraServer.setState({status: "initializing"})
            HurraServer.exec_block("pki", "ovpn_genconfig -u udp://hurravpn", {}).then((command) => {
                HurraServer.exec_block("pki", "ovpn_initpki",
                    {
                        "EASYRSA_BATCH": 1,
                        "EASYRSA_REQ_CN": "HurraVPN",
                        "CA_PASS": req.body.password,
                    }).then(() => {
                        console.log("Done!")
                        HurraServer.setState({status: "initialized"}).then(() => {
                            res.send({done: true})
                        })
                    })
                })
        })
                  
    }

    sanitize_client_name(name) {
        return name.replace(/[^a-z0-9]/gi, '_').toLowerCase();
    }

}

module.exports = HurraApp;
