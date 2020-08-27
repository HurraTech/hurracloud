import React from 'react';
import axios from 'axios'
import  { Redirect } from 'react-router-dom'
class HurraApp extends React.PureComponent {
  constructor(props) {
    super(props);
    this.state = {
    };
  }

  render() {
	return ( window.location = `//${window.location.hostname}:${process.env.REACT_APP_PROXY_PORT}/index.html`)
  }
}


export default HurraApp;
