import axios from 'axios';

export default class HurraUtils {
  static getState() {
    console.log(process.env.REACT_APP_AUID)
    let auid = process.env.REACT_APP_AUID
    return new Promise((resolve, reject) => {
      axios
      .get(`http://192.168.1.2:5000/apps/${auid}`)
      .then(res => {
          resolve(res.data.state)
      })
  
    })
  }

  static setState(state) {
    let auid = process.env.REACT_APP_AUID
    return new Promise((resolve, reject) => {
      axios
      .put(`http://192.168.1.2:5000/apps/${auid}`, {
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
      .post(`http://192.168.1.2:5000/apps/${auid}/${container}/_exec`, {
        cmd: command,
        env: env
      })
      .then(res => {
          resolve(res.data)
      })
  
    })    
  }

  static exec_block(container, command, env = {}) {
    let auid = process.env.REACT_APP_AUID
    return new Promise((resolve, reject) => {
      axios
      .post(`http://192.168.1.2:5000/apps/${auid}/${container}/_exec`, {
        cmd: command,
        env: env
      })
      .then(res => {
        HurraUtils.wait_for_cmd(res.data.command, resolve)
      })
  
    })
  }

  static wait_for_cmd(command, resolver)
  {
    HurraUtils.get_command(command.id).then(command_update => {
      if (command_update.status == "completed")
        resolver(command_update)
      else {
        setTimeout(() => { HurraUtils.wait_for_cmd(command, resolver) }, 1000)
      }
    })
  }

  static get_command(cmd_id) {
    let auid = process.env.REACT_APP_AUID
    return new Promise((resolve, reject) => {
      axios
      .get(`http://192.168.1.2:5000/apps/${auid}/app_commands/${cmd_id}`)
      .then((statusRes) => {
        console.log("Command Status", statusRes.data.status);
        resolve(statusRes.data)
      })    
    })
  }

}

