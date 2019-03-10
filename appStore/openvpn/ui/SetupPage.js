import React from 'react';
import VisibilityOff from '@material-ui/icons/VisibilityOff';
import classNames from 'classnames';
import Visibility from '@material-ui/icons/Visibility';
import {InputAdornment, IconButton, Button, TextField, Typography, withStyles} from '@material-ui/core';
import HurraClient from '../HurraClient'
import { withRouter, Redirect } from 'react-router-dom';
import CircularProgress from '@material-ui/core/CircularProgress';
import Paper from '@material-ui/core/Paper';
import axios from 'axios'

const styles = theme => ({
    root: {
      ...theme.mixins.gutters(),
      paddingTop: theme.spacing.unit * 2,
      paddingBottom: theme.spacing.unit * 2,
      display: 'flex',
      flexDirection: 'column'
    },
  
    title: {
      flexDirection: 'row',
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      fontWeight: 'bold',
      marginBottom:10
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
        this.setState({loading: true}, async () => {
            let status = (await (await fetch('/status')).json()).status;
            if (status === "initializing") {
              this.setState({loading: true, status: status}, () => {
                setTimeout(this.refreshState, 1000);
              })
            } else if (status === "initialized") {
              this.setState({loading: false, status: status}, this.props.onSetupComplete())                  
            }
            else
            {
              this.setState({loading: false, status: status})
            }
      })
    }
  
    savePassword = () => {
        this.setState({loading: true}, async () => {
          let response = await axios.post('/setup', { password: this.state.password });
          this.setState({loading: false, status: "initialized"}, this.props.onSetupComplete())
        });
    }
  
    render = () => {
        const { classes } = this.props;
        if (this.state.status === "initialized")
            return <Redirect to='/' />; 
        if (this.state.loading)
            return (<div className={classes.root}>
                    <CircularProgress className={classes.progress} />
                    </div>)  
        return (
            <Paper className={classes.root}>
                <div className={classes.title} ><Typography variant="h6">Setup</Typography></div>
                <div className={classes.welcomeTextContainer}>
                    <Typography variant="body">
                       Since this is your first time, we need to setup a password for managing your OpenVPN Server. This password will be used to add or remove users, it will not be used when connecting  to the server.                 
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
            </Paper>
        );
    }
}

export default withRouter(withStyles(styles)(SetupPage));
