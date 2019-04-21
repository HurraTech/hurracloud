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
import RevokeUserDialog from './RevokeUserDialog'
import axios from 'axios'
import { saveAs } from 'file-saver';
import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogTitle from '@material-ui/core/DialogTitle';

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

  tableButton: {
    marginLeft: theme.spacing.unit * 2,
    fontSize: 12,
    paddingLeft: theme.spacing.unit,
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

  rightAligned: {
    textAlign: 'right' 
  },

  centerAligned: {
    textAlign: 'center' 
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
      errorDialogMessage: "",
      addUserDialog: false,
      errorDialogOpen: false,
      revokeUserDialog: false,
      selectedUser: null
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

  refreshAll = async () => {
    await this.setState({loading: true})
    let state = (await (await fetch('/refresh')).json());
    let status = state.status
    console.log("Status is", status)
    this.setState({loading: false, status: status, users: state.users })
  }

  refreshState = () => {    
    this.setState({loading: true}, async () => {
        let state = (await (await fetch('/state')).json());
        let status = state.status
        console.log("Status is", status)
        if (status === "initializing") {
          this.setState({loading: true, status: status}, () => {
            setTimeout(this.refreshState, 1000);
          })
        } else {        
          this.setState({loading: false, status: status, users: state.users })
        }
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
    this.setState({status: "adding_user", addUserDialog: false}, async () => {
      let response = (await axios.post('/user', { password: adminPassword, name: name })).data;      
      if (response.status && response.status == "ok") {
        this.setState({status: response.status, users: response.users })
      } else {
        await this.setState({status: "ok"})
        this.showErrorDialog(response.error)
      }
    });

  }

  downloadOVPN = async (client_key) => {
    console.log("Downloading OVPN", client_key)
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

  openRevokeUserDialog = (client_key) => {
    this.setState({revokeUserDialog: true, selectedUser: client_key})
  }

  cancelRevokeUserDialog = () => {
    this.setState({revokeUserDialog: false, selectedUser: null})
  }

  onRevokeUserSave = async (adminPassword) => {
    console.log("Revoking client", this.state.selectedUser)
    await this.setState({revokeUserDialog: false, status: `removing_${this.state.selectedUser}` })
    let response = (await axios.delete(`/users/${this.state.selectedUser}`, { data: { password: adminPassword }})).data
    if (response.status && response.status == "ok") {
      this.setState({status: response.status, users: response.users, selectedUser: null })
    } else {
      await this.setState({status: "ok"})
      this.showErrorDialog(response.error)
    }
  }
  
  showErrorDialog = (message) => {
    this.setState({errorDialogOpen: true, errorDialogMessage: message})
  }

  closeErrorDialog = () => {
    this.setState({errorDialogOpen: false, errorDialogMessage: ""})
  }

  render() {
    const { classes } = this.props;

    if (this.state.loading)
      return (<div className={classes.loader}>
                <CircularProgress className={classes.progress} />
              </div>)

    return <main className={classes.content} >

            <Dialog
                open={this.state.errorDialogOpen}
                onClose={this.closeErrorDialog}
                aria-labelledby="alert-dialog-title"
                aria-describedby="alert-dialog-description"
              >
                <DialogTitle id="alert-dialog-title">{"Error"}</DialogTitle>
                <DialogContent>
                  <DialogContentText id="alert-dialog-description">
                    {this.state.errorDialogMessage}
                  </DialogContentText>
                </DialogContent>
                <DialogActions>
                  <Button onClick={this.closeErrorDialog} color="primary" autoFocus>
                    OK
                  </Button>
                </DialogActions>
              </Dialog>

              <AddUserDialog 
                  open={this.state.addUserDialog} 
                  onClose={this.cancelAddUserDialog.bind(this)}
                  onSave={this.onAddUserSave}
              />    
              <RevokeUserDialog 
                  open={this.state.revokeUserDialog} 
                  onClose={this.cancelRevokeUserDialog.bind(this)}
                  onSave={this.onRevokeUserSave}
              />
              <div className={classes.logoRow}><span className={classes.logo} /><Typography variant="h6" className={classes.title}>OpenVPN Server</Typography></div>               
                <Route path="/setup" render={() => (<SetupPage onSetupComplete={this.onSetupComplete} />)}/>
                <Route exact path="/" render={() => (
                    this.state.status == "uninitialized" ? (<Redirect to="/setup" />) : (<>
                      <Paper className={classes.root} >
                        <Table className={classes.table}>
                          <TableHead>
                              <TableRow className={classes.tableHeaderRow}>
                                <TableCell variant="head" className={classes.tableHeaderCell}>Users List</TableCell>
                                <TableCell variant="head" className={classes.tableHeaderCell}>Created</TableCell>
                                <TableCell variant="head" className={classes.tableHeaderCell}>Expires</TableCell>
                                <TableCell variant="head" className={classes.tableHeaderCell}>Status</TableCell>
                                <TableCell variant="head" className={classes.tableHeaderCell}></TableCell>
                              </TableRow>
                          </TableHead>
                          <TableBody>
                            {Object.keys(this.state.users).map(user_key => {
                              let userStatus = (this.state.users[user_key]["status"] == "INVALID") ? "Inactive" : "Active"
                              if (this.state.status == `removing_${user_key}`) {
                                return (<TableRow><TableCell variant="body" className={classNames(classes.tableRow, classes.centerAligned)} scope="row" colSpan={5} >
                                <CircularProgress className={classes.progress} size={30} />
                                </TableCell></TableRow>)
                              } else {
                                  return (<TableRow>
                                            <TableCell variant="body" className={classNames(classes.tableRow)} scope="row">{this.state.users[user_key]["client_name"]}</TableCell>
                                            <TableCell variant="body" className={classNames(classes.tableRow)} scope="row">{this.state.users[user_key]["created"]}</TableCell>
                                            <TableCell variant="body" className={classNames(classes.tableRow)} scope="row">{this.state.users[user_key]["expires"]}</TableCell>
                                            <TableCell variant="body" className={classNames(classes.tableRow)} scope="row">{userStatus}</TableCell>
                                            <TableCell variant="body"  className={classNames(classes.tableRow, classes.rightAligned)} scope="row">
                                            { userStatus == "Active" && 
                                              <>
                                              <Tooltip title="Donwload File">
                                                <Button  color="inherit" className={classNames(classes.tableButton)} onClick={() => {this.downloadOVPN(user_key)}} >
                                                  <DownloadIcon color="inherit" />
                                                  OpenVPN Config
                                                </Button>
                                              </Tooltip>
                                              <Tooltip title="Revoke Credentials">
                                                <Button color="inherit" className={classNames(classes.tableButton)}  onClick={() => {this.openRevokeUserDialog(user_key)}} >
                                                  <DeleteIcon color="inherit" />
                                                  Revoke Access
                                                </Button>
                                              </Tooltip></>}
                                            </TableCell>
                                  </TableRow>)
                              }
                            })}
                            { this.state.status == "adding_user" && <TableRow>
                              <TableCell variant="body" className={classNames(classes.tableRow, classes.centerAligned)} scope="row" colSpan={5} >
                                <CircularProgress className={classes.progress} size={30} />
                              </TableCell>
                          </TableRow>}
                          </TableBody>
                        </Table>
                        <div className={classes.actionBar}>
                          <Button variant="contained" color="primary" className={classes.button} onClick={this.openAddUserDialog.bind(this)}>Add New User</Button>
                          <Button variant="contained" color="secondary" className={classes.button}  onClick={() => { this.reset()}}>Reset</Button>
                          <Button variant="contained" className={classes.button} onClick={this.refreshAll}>Refresh</Button>
                          <Button variant="contained" className={classes.button} onClick={this.openAddUserDialog.bind(this)}>Help</Button>
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
