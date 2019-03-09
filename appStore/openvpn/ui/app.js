import React from 'react';
import Button from '@material-ui/core/Button';
import Paper from '@material-ui/core/Paper';
import {TextField, Typography} from '@material-ui/core';
import  HurraUtils from '../Utils'
import { withStyles } from '@material-ui/core/styles';
import { Route, withRouter, Redirect } from 'react-router-dom';
import SetupPage from './SetupPage'
import CircularProgress from '@material-ui/core/CircularProgress';

const styles = theme => ({
  root: {
    ...theme.mixins.gutters(),
    paddingTop: theme.spacing.unit * 2,
    paddingBottom: theme.spacing.unit * 2,
    display: 'flex',
    flexDirection: 'column'
  },

  loader: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
  },

  logoRow: {
    flexDirection: 'row',
    height:80,
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
  },

  logo: {
    backgroundRepeat: 'no-repeat',
    backgroundImage: 'url("/static/icon.svg")',
    backgroundSize: 60,
    height:60,
    width: 80,
    display: 'inline-block'
  },

  container: {
    display: 'flex',
    flexWrap: 'wrap',
    flexDirection: 'column',    
  },

  title: {
    fontWeight: 'bold',
  },

  welcomeTextContainer: {
    marginBottom: 15,
  },

  margin: {
    marginTop: 15,
  }
  

});
  

class HurraApp extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      loading: false,
    }
  };

  handleChange = prop => event => {
    this.setState({ [prop]: event.target.value });
  };

  handleClickShowPassword = () => {
    this.setState(state => ({ showPassword: !state.showPassword }));
  };

  handleClickShowConfirmPassword = () => {
    this.setState(state => ({ showConfirmPassword: !state.showConfirmPassword }));
  };

  componentDidMount = () => {
    this.refreshState()
  }

  onSetupComplete = () => {
    console.log("Setup done!")
    this.setState({loading: false, initialized: true})
  }

  refreshState = () => {
    this.setState({loading: true}, () => {
      HurraUtils.getState().then(state => {  
        this.setState({loading: false, initialized: state.initialized || false})
      })
    })
  }

  reset = () => {
    this.setState({loading: true}, () => {
      HurraUtils.exec_block("pki", "rm -rf /etc/openvpn/*", {}).then((command) => {
          HurraUtils.setState({initialized: false}).then(state => {
            this.refreshState()
          })
      })
    })
  }  

  render() {
    const { classes } = this.props;
    if (this.state.loading)
      return (<div className={classes.loader}>
                <CircularProgress className={classes.progress} />
              </div>)

    return <Paper className={classes.root} >
            <div className={classes.logoRow}><span className={classes.logo} /><Typography variant="h6" className={classes.title}>OpenVPN Server</Typography></div>
            <Route path="/setup" render={() => (<SetupPage onSetupComplete={this.onSetupComplete} />)}/>
            <Route exact path="/" render={() => (
                !this.state.initialized ? (<Redirect to="/setup" />) : (<>
                    <div>Welcome</div>
                    <div><Button variant="contained" color="secondary" onClick={() => { this.reset()}}>Reset</Button></div>
                  </>
                ))} />
            </Paper> 

  }
}


export default withRouter(withStyles(styles)(HurraApp));
