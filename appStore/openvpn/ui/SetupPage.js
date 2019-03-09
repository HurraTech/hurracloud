import React from 'react';
import VisibilityOff from '@material-ui/icons/VisibilityOff';
import classNames from 'classnames';
import Visibility from '@material-ui/icons/Visibility';
import {InputAdornment, IconButton, Button, TextField, Typography, withStyles} from '@material-ui/core';
import HurraUtils from '../Utils'
import { withRouter, Redirect } from 'react-router-dom';
import CircularProgress from '@material-ui/core/CircularProgress';

const styles = theme => ({
    root: {
      ...theme.mixins.gutters(),
      paddingTop: theme.spacing.unit * 2,
      paddingBottom: theme.spacing.unit * 2,
      display: 'flex',
      flexDirection: 'column'
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
    
  
class SetupPage extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        showPassword: false,
        showConfirmPassword: false,
        password: '',
        passwordConfirm: '',
        stage: "",
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
  
    refreshState = () => {
        this.setState({loading: true}, () => {
            HurraUtils.getState().then(state => {  
                this.setState({loading: false, initialized: state.initialized || false})
            })
        })
    }
  
    savePassword = (event) => {
        this.setState({loading: true}, () => {
            HurraUtils.exec_block("pki", "ovpn_genconfig -u udp://hurravpn", {}).then((command) => {
                HurraUtils.exec_block("pki", "ovpn_initpki",
                {
                    "EASYRSA_BATCH": 1,
                    "EASYRSA_REQ_CN": "HurraVPN",
                    "CA_PASS": this.state.password,
                }).then(() => {
                    console.log("Done!")
                    HurraUtils.setState({initialized: true}).then(() => {
                        this.setState({loading: false, initialized: true}, this.props.onSetupComplete())                        
                    })
                })
            })
        })
    }
  
    render = () => {
        const { classes } = this.props;
        if (this.state.loading)
            return (<div className={classes.loader}>
                    <CircularProgress className={classes.progress} />
                    </div>)  
        if (this.state.initialized)
            return <Redirect to='/' />; 
        return (
            <div>
                <div className={classes.welcomeTextContainer}>
                    <Typography variant="body">
                        Welcome! Since this is your first time, we need to setup a password for managing your OpenVPN Server. This password will be used to add or remove users, it will not be used when connecting  to the server.                 
                    </Typography>

                    <form className={classes.container} noValidate autoComplete="off">
                        <TextField
                        id="outlined-adornment-password"
                        className={classNames(classes.margin, classes.textField)}
                        variant="outlined"
                        type={this.state.showPassword ? 'text' : 'password'}
                        label="Password"
                        value={this.state.password}
                        onChange={this.handleChange('password')}
                        InputProps={{
                            endAdornment: (
                            <InputAdornment position="end">
                                <IconButton
                                aria-label="Toggle password visibility"
                                onClick={this.handleClickShowPassword}
                                >
                                {this.state.showPassword ? <VisibilityOff /> : <Visibility />}
                                </IconButton>
                            </InputAdornment>
                            ),
                        }}
                        />

                    <TextField
                                id="outlined-adornment-password"
                                className={classNames(classes.margin, classes.textField)}
                                variant="outlined"
                                type={this.state.showConfirmPassword ? 'text' : 'password'}
                                label="Confirm Password"
                                value={this.state.passwordConfirm}
                                onChange={this.handleChange('passwordConfirm')}
                                InputProps={{
                                endAdornment: (
                                    <InputAdornment position="end">
                                    <IconButton
                                        aria-label="Toggle password visibility"
                                        onClick={this.handleClickShowConfirmPassword}
                                    >
                                        {this.state.showConfirmPassword ? <VisibilityOff /> : <Visibility />}
                                    </IconButton>
                                    </InputAdornment>
                                ),
                                }}
                            />
                    </form>
                </div>
                <div>
                    <Button variant="contained" color="primary" onClick={() => { this.savePassword()}}>Save Password</Button>
                </div>
            </div>
        );
    }
}

export default withRouter(withStyles(styles)(SetupPage));
