import React from 'react';
import './App.css';
import { withRouter } from 'react-router-dom';
import HurraApp from './HurraApp/app';

class App extends React.Component {

  render() {
    return (
      <HurraApp />
    );
  }

  
}

App.propTypes = {
};


export default App;
