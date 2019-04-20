import React from 'react';
import Button from '@material-ui/core/Button';
import Paper from '@material-ui/core/Paper';
import {Table, TableHead, TableBody, TableRow, TableCell, Typography, IconButton} from '@material-ui/core';
import classNames from 'classnames';
import { withStyles } from '@material-ui/core/styles';
import { Route, withRouter, Redirect, } from 'react-router-dom';
import SetupPage from './SetupPage'
import CircularProgress from '@material-ui/core/CircularProgress';
import DownloadIcon from '@material-ui/icons/GetApp';
import DeleteIcon from '@material-ui/icons/DeleteForever';
import Tooltip from '@material-ui/core/Tooltip';
import AddUserDialog from './AddUserDialog'
import axios from 'axios'
import { saveAs } from 'file-saver';

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
      addUserDialog: false,
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
    this.setState({loading: false, status: "ok"})
  }

  refreshState = () => {    
    this.setState({loading: true}, async () => {
        let state = (await (await fetch('/state')).json());
        let status = state.status
        console.log("Status is", status)
        this.setState({loading: false, status: status, users: state.users })
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
  
  openAddUserDialog = () => {
    this.setState({addUserDialog: true})
  }

  cancelAddUserDialog = () => {
    this.setState({addUserDialog: false})
  }

  onAddUserSave = (name, adminPassword) => {
    this.setState({status: "adding_removing_user"}, async () => {
      await axios.post('/user', { password: adminPassword, name: name });
      this.setState({status: "ok"}, this.props.onSetupComplete())
    });

  }

  downloadOVPN = async (client_key) => {
    console.log("Downloading file", client_key)
    const response = await fetch(`/users/${client_key}/ovpn`, {
      headers: new Headers({
        'Accept': 'text/plain'
      }), 
    });
    const ovpn_text = await response.text()
    console.log("DONE", ovpn_text)
    var blob = new Blob([ovpn_text], {type: "text/plain;charset=utf-8"});
    saveAs(blob, `HurraCloud-${client_key}.ovpn`);
  }

  render() {
    const { classes } = this.props;

    if (this.state.loading)
      return (<div className={classes.loader}>
                <CircularProgress className={classes.progress} />
              </div>)

    return <main className={classes.content} >
              <AddUserDialog 
                  open={this.state.addUserDialog} 
                  onClose={this.cancelAddUserDialog.bind(this)}
                  onSave={this.onAddUserSave}
              />    
              <div className={classes.logoRow}><span className={classes.logo} /><Typography variant="h6" className={classes.title}>OpenVPN Server</Typography></div>               
                <Route path="/setup" render={() => (<SetupPage onSetupComplete={this.onSetupComplete} />)}/>
                <Route exact path="/" render={() => (
                    this.state.status == "uninitialized" ? (<Redirect to="/setup" />) : (<>
                      <Paper className={classes.root} >
                        <Table className={classes.table}>
                          <TableHead>
                              <TableRow className={classes.tableHeaderRow}>
                                <TableCell variant="head" className={classes.tableHeaderCell} colSpan={2}>Users List</TableCell>
                              </TableRow>
                          </TableHead>
                          <TableBody>
                            {Object.keys(this.state.users).map(user_key => {
                              return (
                              <TableRow>
                                  <TableCell variant="body" className={classNames(classes.tableRow)} scope="row">{this.state.users[user_key]["client_name"]}</TableCell>
                                  <TableCell variant="body">
                                    <Tooltip title="Donwload File">
                                      <IconButton onClick={() => {this.downloadOVPN(user_key)}} >
                                        <DownloadIcon color="inherit" color="primary" />
                                      </IconButton>
                                    </Tooltip>
                                    <Tooltip title="Revoke Credentials">
                                      <IconButton onClick={() => {this.revokeCredentials(user_key)}} >
                                        <DeleteIcon color="inherit" color="secondary" />
                                      </IconButton>
                                    </Tooltip>

                                  </TableCell>
                            </TableRow>)
                            })}
                          </TableBody>
                        </Table>
                        <div className={classes.actionBar}>
                          <Button variant="contained" color="primary" className={classes.button} onClick={this.openAddUserDialog.bind(this)}>Add New User</Button>
                          <Button variant="contained" color="secondary" className={classes.button}  onClick={() => { this.reset()}}>Reset</Button>
                        </div>      
                        <div className={classes.actionBar}>
                          <Typography variant="subtitle2">
                            Create a user above for each person and device you would like to grant remote access. It is recommended to create separate user for each device you own. For example, you can create one for your iOS, and another for your laptop and so on.                            
                          </Typography>                        
                        </div>
                      </Paper>
                      </>
                    ))} />
            </main>

  }
}


export default withRouter(withStyles(styles)(HurraApp));
