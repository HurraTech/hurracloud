import React from 'react';
import Button from '@material-ui/core/Button';
import Paper from '@material-ui/core/Paper';
import {Table, TableHead, TableBody, TableRow, TableCell, Typography, IconButton} from '@material-ui/core';
import  HurraClient from '../HurraClient'
import classNames from 'classnames';
import { withStyles } from '@material-ui/core/styles';
import { Route, withRouter, Redirect, } from 'react-router-dom';
import SetupPage from './SetupPage'
import CircularProgress from '@material-ui/core/CircularProgress';
import DownloadIcon from '@material-ui/icons/GetApp';
import Tooltip from '@material-ui/core/Tooltip';


const styles = theme => ({  
  root: {
    display: 'flex',
    flexDirection: 'column',
    padding: 0,
    marginBottom:15
  },

  paddedPaper: {
    padding: 15,
    borderRadius: 0,
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

  table: {
    marginBottom: 15,
  },

  margin: {
    marginTop: 15,
  },



  content: {
    flexGrow: 1,
    paddingLeft: theme.spacing.unit * 3,
    paddingRight: theme.spacing.unit * 3,
    paddingTop: theme.spacing.unit * 3,
  },

  button: {
    marginRight: 10,
  },

  tableCell: {
    flex: 1,
  },

  tableHeaderCell: {
    flex: 1,
    backgroundColor: 'black',
    color: 'white',
    fontSize: 14,
    fontWeight: 'bold',
    height:42,
  },

  tableHeaderRow: {
    height:32,
  },

  actionBar: {
    padding: 15
  }


});
  

class HurraApp extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      loading: true,
      status: "",
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
    this.setState({loading: false, status: "initialized"})
  }

  refreshState = () => {    
    this.setState({loading: true}, async () => {
        let status = (await (await fetch('/status')).json()).status;
        console.log("Status is", status)
        this.setState({loading: false, status: status })
    })
  }

  reset = () => {
    this.setState({loading: true}, async () => {
    const response = await fetch('/reset');
    const body = await response.json();
    if (response.status !== 200) throw Error(body.message);
      this.refreshState()
    })
  }  

  render() {
    const { classes } = this.props;
    if (this.state.loading)
      return (<div className={classes.loader}>
                <CircularProgress className={classes.progress} />
              </div>)

    return <main className={classes.content} >
              <div className={classes.logoRow}><span className={classes.logo} /><Typography variant="h6" className={classes.title}>OpenVPN Server</Typography></div>               
                <Route path="/setup" render={() => (<SetupPage onSetupComplete={this.onSetupComplete} />)}/>
                <Route exact path="/" render={() => (
                    this.state.status != "initialized" ? (<Redirect to="/setup" />) : (<>
                      <Paper className={classes.root} >
                        <Table className={classes.table}>
                          <TableHead>
                              <TableRow className={classes.tableHeaderRow}>
                                <TableCell variant="head" className={classes.tableHeaderCell} colSpan={2}>Users List</TableCell>
                              </TableRow>
                          </TableHead>
                          <TableBody>
                            <TableRow>
                                <TableCell variant="body" className={classNames(classes.tableRow)} scope="row">Aiman Najjar</TableCell>
                                <TableCell variant="body">
                                  <Tooltip title="Donwload File">
                                    <IconButton href={`http://192.168.1.2:5000/files/download/` } >
                                      <DownloadIcon color="inherit" color="primary" />
                                    </IconButton>
                                  </Tooltip>
                                </TableCell>

                            </TableRow>
                          </TableBody>
                        </Table>
                        <div className={classes.actionBar}>
                          <Button variant="contained" color="primary" className={classes.button} onClick={() => { }}>Add New User</Button>
                          <Button variant="contained" color="secondary" className={classes.button}  onClick={() => { this.reset()}}>Reset</Button>
                        </div>      
                        <div className={classes.actionBar}>
                          <Typography variant="subtitle2">
                            Create a user above for each person and device you would like to grant remote access. It is recommended to create separate user for each device you own. For example, you can create one for your iOS, and another for your laptop,..and so on.                            
                          </Typography>                        
                        </div>
                      </Paper>
                      </>
                    ))} />
            </main>

  }
}


export default withRouter(withStyles(styles)(HurraApp));
