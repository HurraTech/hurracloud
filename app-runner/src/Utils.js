import React from 'react';
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
    console.log(process.env.REACT_APP_AUID)
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
  
  static exec(container, command) {
    
  }
}
