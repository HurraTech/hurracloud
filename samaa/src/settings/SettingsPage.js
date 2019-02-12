import React from 'react';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';
import axios from 'axios';
import AddIcon from '@material-ui/icons/Add';
import Fab from '@material-ui/core/Fab';
import Grid from '@material-ui/core/Grid';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import { Typography, DialogContent, DialogActions, DialogContentText } from '@material-ui/core';
import classNames from 'classnames';
import $ from 'jquery'
import Utils from '../utils'
import Button from '@material-ui/core/Button';
import MountIcon from '@material-ui/icons/PlayForWork'
import UnmountIcon from '@material-ui/icons/EjectRounded'
import IndexIcon from '@material-ui/icons/DescriptionOutlined'
import Tooltip from '@material-ui/core/Tooltip';
import IndexDialog from './IndexDialog';
import AlertDialog from '../components/AlertDialog'
import PauseIcon from '@material-ui/icons/Pause'
import ResumeIcon from '@material-ui/icons/PlayArrowRounded'
import DeleteIcon from '@material-ui/icons/DeleteRounded'
import CancelIcon from '@material-ui/icons/CancelPresentation'
import CircularProgress from '@material-ui/core/CircularProgress';
import NewWindow from 'react-new-window'

import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemAvatar from '@material-ui/core/ListItemAvatar';
import Avatar from '@material-ui/core/Avatar';
import ListItemText from '@material-ui/core/ListItemText';
import DialogTitle from '@material-ui/core/DialogTitle';
import Dialog from '@material-ui/core/Dialog';
import TextField from '@material-ui/core/TextField';

const styles = theme => ({
    root: {
        width: '100%',
        marginTop: theme.spacing.unit * 3,
        overflowX: 'auto',
    },

    tableDescriptionWrapper: {
        padding: "10px",
        fontSize: '11pt',
        backgroundColor: 'white',
    },

    descriptionTitle: {
        fontSize: '13pt',
    },

    descriptionContent: {
        paddingRight: '15px',
        lineHeight: '22px',
        fontFamily: 'Tahoma'
    },

    fabWrapper: {
        padding: 'relative',
        float: 'right',
        marginTop: '-25px',
        marginRight: '35px',
        zIndex: 999
    },

    createButton: {
        position: 'absolute',
        zIndex: 999,
        marginRight: '-10px'
    },

    leftIcon: {
        marginRight: theme.spacing.unit,
    },

    rightIcon: {
        marginLeft: theme.spacing.unit,
    },

    iconSmall: {
        fontSize: 20,
    },
    
    tableButton: {
        margin: theme.spacing.unit,
    },

    partitionRow: {
        backgroundColor: '#f7f7f7'
    },

    sourceRow: {
        backgroundColor: '#e8e8e8',
    },


    tableHeader: {
        backgroundColor: theme.palette.grey[900],
        color: 'white',
        height: '32px',
        fontSize: '11pt',
        padding :0,
    },

    bodyCell: {
        padding: 0
    },

    iconCell: {
        maxWidth: '35px',
        padding: '0px',
        paddingLeft: '15px',
        paddingRight: '15px'
    },

    nameCell: {
        padding: '0px',
        width: '250px'
    },

    capacityCell: {
        width: '100px'
    },

    availableCell: {
        width: '100px'        
    },

    actionsCell: {
        minWidth:'300px'
    },

    headerCell: {

    },

    indexCell: {
        width: '350px',
        padding: '0px',
    },

    indexTools: {
        float: 'right',
        clear: 'both'
    },

    progress: {
        marginTop: theme.spacing.unit,
        marginLeft: theme.spacing.unit * 5,
        padding:'2px'
      },    

});
class SettingsPage extends React.Component {

    constructor(props, context) {
        super(props)
        this.state = {
            indices: [],
            sources: this.props.sources || [],
            indexDialogOpen: false,
            selectedPartition: {},
            unmountAlertOpen: false,
            addDialogOpen: false,
            googleAuthConsentOpen: false,
            consentFlowState: ""
        }
    }

    static prettyTypeName(name) {
        switch(name) {
            case "usb":
                return "Removable Media (USB)"
            case "internal_storage":
                return "Internal Storage"
            case "system":
                return "System Storage"
        }
    }

    handleMountClick(source) {
        var currentSources = [...this.state.sources]
        let source_id = source.id
        currentSources.find(s => s.id === source_id).status = "mounting"
        this.setState({sources: currentSources}, () => {
            axios.get(`http://192.168.1.2:5000/sources/${source_id}/_mount`)
        })
    }

    handlePauseClick(source) {
        var currentSources = [...this.state.sources]
        currentSources.find(s => s.id === source.id).index.status = "pausing"
        this.setState({sources: currentSources}, () => {
            axios.get(`http://192.168.1.2:5000/indices/${source.index.id}/_pause`)
        })
    }

    handleResumeClick(source) {
        var currentSources = [...this.state.sources]
        currentSources.find(s => s.id === source.id).index.status = "resuming"
        this.setState({sources: currentSources}, () => {
            axios.get(`http://192.168.1.2:5000/indices/${source.index.id}/_resume`)
        })
    }

    /* --------- Cancel Index ----------- */
    handleCancelClick(source) {
        this.setState({ cancelIndexAlertOpen: true, selectedPartition: source });
    }

    doCancelIndex(source) {
        var currentSources = [...this.state.sources]
        currentSources.find(s => s.id === source.id).index.status = "cancelling"
        this.setState({sources: currentSources}, () => {
            axios.get(`http://192.168.1.2:5000/indices/${source.index.id}/_cancel`)
        })

    }

    confirmCancelAlert = () => {
        this.doCancelIndex(this.state.selectedPartition);
        this.setState({ cancelIndexAlertOpen: false });
    }

    cancelCancelAlert = () => {        
        this.setState({ cancelIndexAlertOpen: false });
    }

    /* --------- Delete Index ----------- */
    handleDeleteIndexClick(source) {
        this.setState({ deleteIndexAlertOpen: true, selectedPartition: source });
    }

    doDeleteIndex(source) {
        var currentSources = [...this.state.sources]
        currentSources.find(s => s.id === source.id).index.status = "deleting"
        this.setState({sources: currentSources}, () => {
            axios.get(`http://192.168.1.2:5000/indices/${source.index.id}/_delete`)
        })

    }
    
    confirmDeleteAlert = () => {
        this.doDeleteIndex(this.state.selectedPartition);
        this.setState({ deleteIndexAlertOpen: false });
    }

    cancelDeleteAlert = () => {        
        this.setState({ deleteIndexAlertOpen: false });
    }

    /* --------- Unmount Source ----------- */
    handleUnmountClick(source) {
        if (source.index && source.index.status == "indexing") {
            this.setState({ unmountAlertOpen: true, selectedPartition: source });
        }
        else {
            this.doUnmountParition(source.id)            
        }
    }

    confirmUnmountAlert = () => { 
        this.doUnmountParition(this.state.selectedPartition.id)
        this.setState({ unmountAlertOpen: false });
    }

    cancelUnmountAlert = () => {
        this.setState({ unmountAlertOpen: false });
    }

    doUnmountParition(source_id)
    {
        var currentSources = [...this.state.sources]
        currentSources.find(s => s.id === source_id).status = "unmounting"
        this.setState({sources: currentSources}, () => {
            axios.get(`http://192.168.1.2:5000/sources/${source_id}/_unmount`)
        })

    }


    /* ------- Create Index ------- */

    openIndexDialog(source) {
        this.setState({
            indexDialogOpen: true,
            selectedPartition: source
        })
    }

    cancelIndexDialog() {
        console.log("Closing index dialog")
        this.setState({
            indexDialogOpen: false,
            selectedPartition: {}
        })
    }

    onIndexDialogSave = (settings) => {
        const data = {
            index: {
                source_id: this.state.selectedPartition.id,
                settings: settings
            }
        }
        console.log("Calling create index with data", data)
        axios
        .post('http://192.168.1.2:5000/indices/', data)
        .then(res => {
            this.setState({
                indexDialogOpen: false,
                selectedPartition: {}
            })    
        })
    }


    /* ---------- Update Sources --------- */
    componentDidUpdate = (prevProps, prevState, snapshot) => {
        if (JSON.stringify(this.props.sources) != JSON.stringify(prevProps.sources)) {
            this.setState({ 
                sources: this.props.sources
            }, () => {
                this.forceUpdate()
                $(document).ready(function() {
                    $(".meter > span").each(function() {
                        $(this).css("max-width", "1000px")
                    })
                }); 
            })
        }
    }

    /* --------- Add Account Dialog -------*/
    handleAddDialogClose = () => {
        this.setState({
            addDialogOpen: false
        })
    }

    openAddDialog = () => {
        this.setState({
            addDialogOpen: true,
            consentFlowState: "selectProvider"
        })
    }

    responseGoogle = (response) => {
        console.log(response);
    }

    openGoogleAuthConsent = () => {
        this.createGoogleAuthWindow()
        this.setState({
            googleAuthConsentOpen: true,
            googleAuthCode: "",
            consentFlowState: "enterGoogleAuthCode"
        })
    }

    createGoogleAuthWindow = () => {
        this.currentAuthWindow = <NewWindow 
                key={Math.random().toString(36).replace(/[^a-z]+/g, '') }
                url="https://accounts.google.com/o/oauth2/v2/auth?scope=email%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive.readonly&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&client_id=647498924470-rvr9l3drsfmnc3k7cnghrvn8jd2k42l8.apps.googleusercontent.com" 
                center="screen" />
    }

    addGoogleAccount = () => {
        const data = {
            authCode: this.state.googleAuthCode
        }
        console.log("Calling create index with data", data)
        axios
        .post('http://192.168.1.2:5000/google_drive_accounts/', data)        
    }
      
      
    /* ---------- Render --------- */
    render() {
        const { classes } = this.props;
        const { sources, indexDialogOpen, selectedPartition } = this.state
        return (
            <div>
                {this.state.googleAuthConsentOpen && this.currentAuthWindow}

                <IndexDialog 
                    open={indexDialogOpen} 
                    partitionObject={selectedPartition}
                    onClose={this.cancelIndexDialog.bind(this)}
                    onSave={this.onIndexDialogSave}
                    onCancel
                />
                <AlertDialog open={this.state.unmountAlertOpen}
                    cancelButton="Cancel"
                    okButton="Yes"
                    title="This will interrupt indexing progress. Continue?"
                    message="Indexing is currently in progress. Unmounting the storage partition will interrupt the indexing process and may cause some loss of progress. Are you sure you want to continue?" 
                    onCancel={this.cancelUnmountAlert}
                    onOk={this.confirmUnmountAlert}
                />
                <AlertDialog open={this.state.deleteIndexAlertOpen}
                    cancelButton="Cancel"
                    okButton="Yes"
                    title="This will make your files non-searchable. Continue?"
                    message="Deleting the index will makes your files on this partition non-searchable, you can re-create the index later but it might take time depending on data size. Are you sure you want to continue?"
                    onCancel={this.cancelDeleteAlert}
                    onOk={this.confirmDeleteAlert}
                />
                <AlertDialog open={this.state.cancelIndexAlertOpen}
                    cancelButton="Cancel"
                    okButton="Yes"
                    title="Are you sure you want to cancel index creation?"
                    message="You will be able to tempoarirly pause index creation after the index has been initialized."
                    onCancel={this.cancelCancelAlert}
                    onOk={this.confirmCancelAlert}
                />


                <Dialog onClose={this.handleAddDialogClose}
                        open={this.state.addDialogOpen}
                        maxWidth="sm"
                        fullWidth>
                    {this.state.consentFlowState == "selectProvider" && (<><DialogTitle id="simple-dialog-title">Add External Storage Accounts</DialogTitle>
                        <DialogContent>
                        <DialogContentText>
                            Select an account type to connect your HurraCloud Device with.
                        </DialogContentText>
                        <List>
                            <ListItem button onClick={this.openGoogleAuthConsent}>
                                <ListItemAvatar>
                                    <Avatar><span class="google-drive-icon" /></Avatar>
                                </ListItemAvatar>
                                <ListItemText primary="Google Drive" />
                            </ListItem>
                        </List></DialogContent></>)
                    }
                    {this.state.consentFlowState == "enterGoogleAuthCode" && (
                    <><DialogTitle id="simple-dialog-title">Enter Google Authorization Code</DialogTitle>
                        <DialogContent>
                            <DialogContentText>
                                Please complete the authentication process with Google in the popup window and provide the authorization code below:
                            </DialogContentText>
                            <List>
                                <ListItem>
                                    <TextField 
                                        variant="outlined" 
                                        fullWidth 
                                        label="Authorization Code"
                                        value={this.state.googleAuthCode}
                                        onChange={(e) => { this.setState({googleAuthCode: e.target.value}) }}
                                        />
                                </ListItem>
                            </List>
                            <DialogActions>
                                <Button onClick={this.handleClose} color="secondary">
                                Cancel
                                </Button>
                                <Button onClick={this.addGoogleAccount} color="secondary">
                                Add Account
                                </Button>
                            </DialogActions>
                            <DialogContentText variant="body2" align="justify">
                                <b>Why do I need authorization code?</b> The authorization code is needed to allow your HurraCloud Device to access your Google Drive files, therefore enable features such as files sync and backups. <br/><br/>
                                <b>But why enter it manually?</b> You may have seen other applications that automatically completes the consent process without requiring you to copy/paste the code. This is because they use server-side application to retrieve the code from Google. But since HurraCloud is all about privacy, we do not use any servers on the internet. In fact, the entire process completely happens at your HurraCloud Device (and of course, Google's login server)
                            </DialogContentText>
                        </DialogContent>
                    </>)
                    }

                </Dialog>

                <Grid container direction="column">
                    <Grid container direction="row" spacing={32} xs={12} justify="space-between">
                    <Grid item xs={12}>
                            <Paper className={classes.root}>
                                <div className={classes.fabWrapper}>
                                <Fab aria-label="Create Index" color="secondary" className={classes.createButton} onClick={this.openAddDialog}>
                                    <AddIcon  />
                                </Fab>
                                </div>

                                <div className={classes.tableDescriptionWrapper}>
                                    <Typography variant="title" className={classes.descriptionTitle}>
                                    Storage Indexes
                                    </Typography>
                                    <Typography variant="body" align="justify" className={classes.descriptionContent}>
                                        Your HurraCloud device comes with internal storage. You can also connect external USB devices or connect with online cloud storage such as Google Drive, Dropbox and iCloud
                                    </Typography>
                                </div>
                                <Table className={classes.table}>
                                    <TableHead>
                                        <TableRow>
                                            <TableCell variant="head" component='div' className={classNames(classes.tableHeader, classes.iconCell)} scope="row"></TableCell>
                                            <TableCell variant="head" component='div' className={classNames(classes.tableHeader, classes.nameCell)} scope="row">Name</TableCell>
                                            <TableCell variant="head" component='div'  className={classNames(classes.tableHeader, classes.capacityCell)} align="left">Capacity</TableCell>
                                            <TableCell variant="head" component='div'  className={classNames(classes.tableHeader, classes.availableCell)} align="left">Free</TableCell>
                                            <TableCell variant="head" component='div'  className={classNames(classes.tableHeader, classes.actionsCell)} align="left" >Actions</TableCell>
                                            <TableCell variant="head" component='div'  className={classNames(classes.tableHeader, classes.indexCell)} align="left">Index Status</TableCell>
                                        </TableRow>
                                    </TableHead>
                                    <TableBody>
                                        {sources.map(source => {
                                            let icon_class = "fab fa-usb"
                                            if (source.source_type == "system")
                                                icon_class = "fas fa-database"
                                            else if (source.source_type == "internal")
                                                icon_class = "fab fa-hdd"
                                            let partition = source
                                            let indexingProgress = partition.index && partition.index.progress < 100 ? ` - ${partition.index.progress}%` : ''
                                            let partition_name = partition.name
                                            return (
                                            <TableRow key={partition.id} className={classes.partitionRow}>
                                                <TableCell scope="row" className={classes.iconCell}>
                                                    <div style={{float:'left'}}>
                                                        <span className={`${icon_class}`} style={{ marginRight: '0.5em' }} />
                                                    </div>                                                         
                                                </TableCell>
                                                <TableCell scope="row" className={classNames(classes.bodyCell, classes.nameCell)}>
                                                    {partition_name}
                                                </TableCell>
                                                <TableCell scope="row" className={classNames(classes.bodyCell, classes.capacityCell)}>
                                                {partition.status == "mounted" && Utils.humanFileSize(partition.size)}
                                                </TableCell>
                                                <TableCell scope="row" className={classNames(classes.bodyCell, classes.availableCell)}>
                                                {partition.status == "mounted" && Utils.humanFileSize(partition.free)}
                                                </TableCell>
                                                <TableCell align="left"  className={classNames(classes.bodyCell, classes.actionsCell)}>
                                                <div style={{width: "120px", float: 'left', minHeight: '1px'}}>
                                                    { (() => {
                                                        if (partition.status == "mounted") 
                                                            return <Tooltip title="Unmounting the drive will make it inaccessible.">
                                                                        <Button variant="outline" color="primary" size="small" onClick={() => {this.handleUnmountClick(partition)} }>
                                                                            <UnmountIcon className={classes.leftIcon}></UnmountIcon>
                                                                            Unmount
                                                                        </Button>
                                                                    </Tooltip>
                                                        else if (partition.status == "unmounted") 
                                                            return <Tooltip title="Mounting a drive partition allows you to browse its contents via the browser and the mobile and desktop apps">
                                                                        <Button variant="outline" color="primary" size="small" onClick={() => {this.handleMountClick(partition)} }>
                                                                            <MountIcon className={classes.leftIcon}></MountIcon>
                                                                            Mount
                                                                        </Button>
                                                                    </Tooltip>
                                                        else
                                                            return <CircularProgress className={classes.progress} size={20} />
                                                        })()
                                                    }
                                                    </div>
                                                    <div style={{width: "150px", float: 'left', minHeight: '1px'}}>
                                                    {!partition.index && partition.status == "mounted" && (
                                                        <Tooltip title="Indexing a drive partitions allows your to search your files and their contents in blazing speed">
                                                            <Button variant="outline"
                                                                    color="primary" size="small"
                                                                    onClick={() => { this.openIndexDialog(partition) }}>
                                                                <IndexIcon className={classes.leftIcon}></IndexIcon>
                                                                Create Index
                                                            </Button>
                                                        </Tooltip>)
                                                    }
                                                    {partition.index && (partition.index.status == "init" || partition.index.status == "scheduled") && (
                                                        <Tooltip title="You can cancel index creation while it's being intialized or scheduled. You will have the opportuinity to temporarily pause after intialization has completed">
                                                            <Button variant="outline"
                                                                    color="primary" size="small"
                                                                    onClick={() => { this.handleCancelClick(partition) }}>
                                                                <CancelIcon className={classes.leftIcon}></CancelIcon>
                                                                Cancel
                                                            </Button>
                                                        </Tooltip>)
                                                    }
                                                    {partition.index && partition.index.status === "cancelling"  && (
                                                        <CircularProgress className={classes.progress} size={20} />
                                                    )}                             

                                                    {partition.index && partition.status == "mounted" && partition.index.status === "indexing" && (
                                                    <Button variant="outline"
                                                        color="primary" size="small"
                                                        onClick={() => { this.handlePauseClick(source)}}>
                                                        <PauseIcon className={classes.leftIcon}></PauseIcon>Pause
                                                    </Button>)}
                                                    
                                                    {partition.index && partition.status == "mounted" && partition.index.status === "paused" && (
                                                    <Button variant="outline"
                                                        color="primary" size="small"
                                                        onClick={() => { this.handleResumeClick(source)}}>
                                                        <ResumeIcon className={classes.leftIcon}></ResumeIcon>Resume
                                                    </Button>)}

                                                    {partition.index && (partition.index.status === "resuming" || partition.index.status === "pausing")  && (
                                                        <CircularProgress className={classes.progress} size={20} />
                                                    )}                             
                                                    </div>
                                                    <div style={{width: "180px", float: 'left', clear: 'right', minHeight: '1px'}}>
                                                    {partition.index && (partition.index.status === "paused" || partition.index.status === "completed") && (
                                                        <Button variant="outline"
                                                            color="primary" size="small"
                                                            onClick={() => { this.handleDeleteIndexClick(partition)}}>
                                                            <DeleteIcon className={classes.leftIcon}></DeleteIcon>Delete Index
                                                        </Button>
                                                    )}
                                                    {partition.index && partition.index.status === "deleting"  && (
                                                        <CircularProgress className={classes.progress} size={20} />
                                                    )}                             

                                                    </div>
                                                    
                                                </TableCell>
                                                {partition.index && <><TableCell align="left" className={classNames(classes.bodyCell,classes.indexCell)}>
                                                    <div className="indexingDone" style={{display: partition.index.status == "completed" ? "block" : "none" }}>
                                                        <i style={{fontSize: 16, color: 'green'}} class="fas fa-check-circle"></i>
                                                    </div>
                                                    <div className="indexingDone" style={{display: ["paused", "pausing", "resuming"].includes(partition.index.status) ? "block" : "none" }}>
                                                        <i style={{fontSize: 17, color: '#F86395'}} class="fas fa-pause-circle"></i>
                                                    </div>
                                                    <div className="indexingDone" style={{display: ["scheduled", "deleting"].includes(partition.index.status) ? "block" : "none" }}>
                                                        <i style={{fontSize: 16, color: 'orange'}} class="fas fa-clock"></i>
                                                    </div>

                                                    { (partition.index.status == "init" || partition.index.status == "indexing") && partition.index.progress < 100 && (<div className="meter orange">
                                                                                                <span style={{width: `${partition.index.progress}%` }} />
                                                                                            </div>)}
                                                    {partition.index.status == "scheduled" && "Scheduled" }                                                                                                  
                                                    {partition.index.status == "init" && "Initializing index (scanning files)" }
                                                    {!["init", "scheduled", "cancelling", "deleting"].includes(partition.index.status) && `${partition.index.indexed_count} document(s) ${indexingProgress}`}
                                                    
                                                </TableCell>
                                                </>}
                                                {!partition.index && <TableCell className={classNames(classes.bodyCell,classes.indexCell)}>Not indexed</TableCell>}
                                            </TableRow>)

                                        })}
                                    </TableBody>
                                </Table>
                            </Paper>
                        </Grid>                
                    </Grid>
                </Grid>
            </div>
            );
    }
        
}

SettingsPage.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(SettingsPage);
