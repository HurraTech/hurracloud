import HurraServer from '../HurraServer'

class HurraApp {

    constructor(server) {
        this.server = server
    }

    start() {
        this.setupRoutes()
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

        this.server.get('/status', async (req, res) => {
            let state = await HurraServer.getState()
            res.send({status: state.status || "uninitialized"})            
        })

        this.server.post('/setup', (req, res) => {
            HurraServer.setState({status: "initializing"})
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

}

module.exports = HurraApp;
