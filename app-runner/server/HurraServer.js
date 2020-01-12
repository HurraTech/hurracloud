import axios from 'axios';

export default class HurraServer {
  static getState() {
    let auid = process.env.REACT_APP_AUID
    return new Promise((resolve, reject) => {
      axios
      .get(`http://jawhar.cloud/apps/${auid}`)
      .then(res => {
        console.log("RESULT OF STATE IS", res.data.state)
          resolve(res.data.state)
      })
  

    })
  }

  static setState(state) {
    let auid = process.env.REACT_APP_AUID
    return new Promise((resolve, reject) => {
      axios
      .put(`http://jawhar.cloud/apps/${auid}`, {
        app: {
          state: state
        }
      })
      .then(res => {
          resolve(res.data.state)
      })
  
    })
  }

  static patchState(state) {
    let auid = process.env.REACT_APP_AUID
    return new Promise((resolve, reject) => {
      axios
      .patch(`http://jawhar.cloud/apps/${auid}`, {
        app: {
          state: state
        }
      })
      .then(res => {
          resolve(res.data.state)
      })
  
    })
  }

  static exec(container, command, env = {}) {
    let auid = process.env.REACT_APP_AUID
    return new Promise((resolve, reject) => {
      axios
      .post(`http://jawhar.cloud/apps/${auid}/${container}/_exec`, {
        cmd: command,
        env: env
      })
      .then(res => {
          resolve(res.data)
      })
  
    })    
  }

  static restart_container(container) {
    let auid = process.env.REACT_APP_AUID
    return new Promise((resolve, reject) => {
      axios
      .get(`http://jawhar.cloud/apps/${auid}/${container}/_restart`)
      .then(res => {
          resolve(res.data)
      })
  
    })    
  }

  static start_container(container) {
    let auid = process.env.REACT_APP_AUID
    return new Promise((resolve, reject) => {
      axios
      .get(`http://jawhar.cloud/apps/${auid}/${container}/_start`)
      .then(res => {
          resolve(res.data)
      })
  
    })    
  }

  static stop_container(container) {
    let auid = process.env.REACT_APP_AUID
    return new Promise((resolve, reject) => {
      axios
      .get(`http://jawhar.cloud/apps/${auid}/${container}/_stop`)
      .then(res => {
          resolve(res.data)
      })
  
    })    
  }


  static exec_sync(container, command, env = {}) {
    let auid = process.env.REACT_APP_AUID
    return new Promise((resolve, reject) => {
      axios
      .post(`http://jawhar.cloud/apps/${auid}/${container}/_exec`, {
        cmd: command,
        env: env
      })
      .then(res => {
        HurraServer.wait_for_cmd(res.data.command, resolve)
      })
  
    })
  }

  static wait_for_cmd(command, resolver)
  {
    HurraServer.get_command(command.id).then(command_update => {
      if (command_update.status == "completed")
        resolver(command_update)
      else {
        setTimeout(() => { HurraServer.wait_for_cmd(command, resolver) }, 1000)
      }
    })
  }

  static get_command(cmd_id) {
    let auid = process.env.REACT_APP_AUID
    return new Promise((resolve, reject) => {
      axios
      .get(`http://jawhar.cloud/apps/${auid}/app_commands/${cmd_id}`)
      .then((statusRes) => {
        console.log(`Command ${cmd_id} Status`, statusRes.data.status);
        resolve(statusRes.data)
      })    
    })
  }

}

