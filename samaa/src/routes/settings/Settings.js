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
import { Typography } from '@material-ui/core';
import classNames from 'classnames';
import $ from 'jquery'
import Utils from '../../utils'
import Button from '@material-ui/core/Button';
import MountIcon from '@material-ui/icons/PlayCircleFilledWhiteOutlined'
import UnmountIcon from '@material-ui/icons/EjectOutlined'
import IndexIcon from '@material-ui/icons/DescriptionOutlined'
import Tooltip from '@material-ui/core/Tooltip';
import IndexDialog from './IndexDialog';
import AlertDialog from '../../components/AlertDialog'
import PauseIcon from '@material-ui/icons/Pause'
import IconButton from '@material-ui/core/IconButton';

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
        maxWidth: '1px',
        padding: '0px',
        paddingLeft: '25px'
    },

    nameCell: {
        padding: '0px',
        maxWidth: '80x'
    },

    capacityCell: {
        maxWidth: '50px'
    },

    availableCell: {
        maxWidth: '50px'        
    },

    typeCell: {
        maxWidth:'125px'
    },

    headerCell: {

    },

    indexCell: {
        minWidth: '170px',
        padding: '0px',
    },

    actionCell: {
        maxWidth: '1px'
    },

    indexTools: {
        float: 'right',
        clear: 'both'
    }

});

let id = 0;
function createData(name, calories, fat, carbs, protein) {
    id += 1;
    return { id, name, calories, fat, carbs, protein };
}

const rows = [
    createData('Frozen yoghurt', 159, 6.0, 24, 4.0),
    createData('Ice cream sandwich', 237, 9.0, 37, 4.3),
    createData('Eclair', 262, 16.0, 24, 6.0),
    createData('Cupcake', 305, 3.7, 67, 4.3),
    createData('Gingerbread', 356, 16.0, 49, 3.9),
];

class IndexingTable extends React.Component {

    constructor(props) {
        super(props)
        this.state = {
            indices: [],
            sources: [],
            indexDialogOpen: false,
            selectedPartition: {},
            unmountAlertOpen: false
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

    handleMountClick(source_id, partition_id) {
        console.log(source_id, partition_id)

        axios
        .get(`http://192.168.1.2:5000/sources/${source_id}/_mount/${partition_id}`)
        .then(res => {
            console.log(res)
        })
    }

    handleUnmountClick(partition) {
        if (partition.index && (partition.index.status == "initial_indexing" || partition.index.status == "initial_indexing")) {
            this.setState({ unmountAlertOpen: true, selectedPartition: partition });
        }
        else {
            this.doUnmountParition(partition)            
        }
    }

    openUnmountAlert() {
        this.setState({ unmountAlertOpen: true });
    }

    cancelUnmountAlert = () => {
        this.setState({ unmountAlertOpen: false });
    }

    confirmUnmountAlert = () => { 
        this.doUnmountParition(this.state.selectedPartition)
        this.setState({ unmountAlertOpen: false });
    }

    doUnmountParition(partition)
    {
        axios
        .get(`http://192.168.1.2:5000/sources/${partition.source_id}/_unmount/${partition.id}`)
        .then(res => {
            console.log(res)
        })        
    }

    openIndexDialog(partition) {
        this.setState({
            indexDialogOpen: true,
            selectedPartition: partition
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
                device_partition_id: this.state.selectedPartition.id,
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

    componentDidMount() {
        this.getSources()
        this.timer = setInterval(()=> this.getSources(), 1000);

        
    }

    getSources = () => {
        axios
        .get('http://192.168.1.2:5000/sources')
        .then(res => {
            this.setState({ 
                sources: res.data
            }, () => {
                this.forceUpdate()
                $(document).ready(function() {
                    $(".meter > span").each(function() {
                        $(this).css("max-width", "1000px")
                    })
                }); 
            })
        })
    }

    render() {
        const { classes } = this.props;
        const { sources, indexDialogOpen, selectedPartition } = this.state
        return (
            <div>
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
                <Grid container direction="column">
                    <Grid container direction="row" spacing={32} xs={12} justify="space-between">
                    <Grid item xs={12}>
                            <Paper className={classes.root}>
                                <div className={classes.fabWrapper}>
                                <Fab aria-label="Create Index" color="secondary" className={classes.createButton}>
                                    <AddIcon />
                                </Fab>
                                </div>

                                <div className={classes.tableDescriptionWrapper}>
                                    <Typography variant="title" className={classes.descriptionTitle}>
                                    Devices & Accounts
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
                                            <TableCell variant="head" component='div'  className={classNames(classes.tableHeader, classes.typeCell)} align="left" >Type</TableCell>
                                            <TableCell variant="head" component='div'  className={classNames(classes.tableHeader, classes.indexCell)} align="left">Index Status</TableCell>
                                            <TableCell variant="head" component='div'  className={classNames(classes.tableHeader, classes.actionsCell)} align="left"></TableCell>
                                        </TableRow>
                                    </TableHead>
                                    <TableBody>
                                        {sources.map(source => {
                                            let icon_class = "fab fa-usb"
                                            if (source.source_type == "system")
                                                icon_class = "fas fa-database"
                                            else if (source.source_type == "internal")
                                                icon_class = "fab fa-hdd"
                                            let partitions = [];
                                            let all_mounted = source.device_partitions.reduce((all_mounted, partition) => all_mounted && partition.mounted, true)
                                            let total_free = source.device_partitions.reduce((sum, partition) => sum + (partition.available||0), 0)
                                            if (source.source_type != "system")
                                                partitions = source.device_partitions.map((partition) =>{
                                                    let indexingProgress = partition.index && partition.index.progress < 100 ? ` - ${partition.index.progress}%` : ''
                                                    let partition_name = partition.label
                                                    return (<TableRow key={source.id} className={classes.partitionRow}>
                                                        <TableCell scope="row" className={classes.iconCell}></TableCell>
                                                        <TableCell scope="row" className={classNames(classes.bodyCell, classes.nameCell)}>
                                                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                            {partition_name}
                                                        </TableCell>
                                                        <TableCell scope="row" className={classNames(classes.bodyCell, classes.capacityCell)}>
                                                        {partition.mounted && Utils.humanFileSize(partition.size)}
                                                        </TableCell>
                                                        <TableCell scope="row" className={classNames(classes.bodyCell, classes.availableCell)}>
                                                        {partition.mounted && Utils.humanFileSize(partition.available)}
                                                        </TableCell>
                                                        <TableCell align="left"  className={classNames(classes.bodyCell, classes.typeCell)}>
                                                            <div style={{width:'120px', float:'left'}}>
                                                            { (() => {
                                                                if (partition.mounted) 
                                                                    return <Tooltip title="Unmounting the drive will make it inaccessible.">
                                                                                <Button variant="outline" color="primary" size="small" onClick={() => {this.handleUnmountClick(partition)} }>
                                                                                    <UnmountIcon className={classes.leftIcon}></UnmountIcon>
                                                                                    Unmount
                                                                                </Button>
                                                                            </Tooltip>
                                                                else 
                                                                    return <Tooltip title="Mounting a drive partition allows you to browse its contents via the browser and the mobile and desktop apps">
                                                                                <Button variant="outline" color="primary" size="small" onClick={() => {this.handleMountClick(source.id, partition.id)} }>
                                                                                    <MountIcon className={classes.leftIcon}></MountIcon>
                                                                                    Mount
                                                                                </Button>
                                                                            </Tooltip>
                                                                })()
                                                            }
                                                            </div>
                                                            <div style={{width:'120px', float:'left'}}>
                                                                <Tooltip title="Indexing a drive partitions allows your to search your files and their contents in blazing speed">
                                                                    <Button variant="outline"
                                                                            color="primary" size="small"
                                                                            onClick={() => { this.openIndexDialog(partition) }}>
                                                                        <IndexIcon className={classes.leftIcon}></IndexIcon>
                                                                        Index
                                                                    </Button>
                                                                </Tooltip>
                                                            </div>
                                                        </TableCell>
                                                        {partition.index && <><TableCell align="left" className={classNames(classes.bodyCell,classes.indexCell)}>
                                                            <div className="indexingDone" style={{display: partition.index.progress >= 100 ? "block" : "none" }}>
                                                                <i style={{fontSize: 16, color: 'green'}} class="fas fa-check-circle"></i>
                                                            </div>

                                                            { partition.index.progress < 100 && (<div className="meter orange">
                                                                                                        <span style={{width: `${partition.index.progress}%` }} />
                                                                                                  </div>)}
                                                            {partition.index.progress == 0 ? "Initializing index" : `${partition.index.indexed_count} document(s) ${indexingProgress}`}
                                                        </TableCell>
                                                        </>}
                                                        {!partition.index && <TableCell className={classNames(classes.bodyCell,classes.indexCell)}>Not indexed</TableCell>}
                                                        <TableCell>
                                                                <IconButton aria-label="Pause">
                                                                    <PauseIcon fontSize="small" />
                                                                </IconButton>                                                            
                                                        </TableCell>
                                                    </TableRow>)
                                                })
                                            return (
                                                <>
                                                <TableRow key={source.id} className={classes.sourceRow}>
                                                    <TableCell scope="row" className={classes.iconCell}>
                                                    <div style={{float:'left'}}><span
                                                    className={`${icon_class}`}
                                                    style={{ marginRight: '0.5em' }}
                                                    />
                                                    </div> 
                                                    </TableCell>
                                                    <TableCell scope="row" className={classNames(classes.bodyCell, classes.nameCell)}>
                                                    <span style={{fontWeight:500}}>
                                                    {source.source_type == "system" ? "System Drive": source.name}
                                                    </span> 
                                                    </TableCell>
                                                    <TableCell scope="row" className={classNames(classes.bodyCell, classes.capacityCell)}>
                                                    {Utils.humanFileSize(source.capacity*1024)}
                                                    </TableCell>
                                                    <TableCell scope="row" className={classNames(classes.bodyCell, classes.availableCell)}>{(source.source_type == "system" || source.source_type == "internal_storage" || all_mounted) 
                                                                    && Utils.humanFileSize(total_free*1024)}</TableCell>
                                                    <TableCell align="left"  className={classNames(classes.bodyCell, classes.typeCell)} colSpan={3}>
                                                    <div style={{paddingTop:'6px'}}>
                                                        {IndexingTable.prettyTypeName(source.source_type)}
                                                    </div>
                                                    </TableCell>
                                                </TableRow>
                                                {partitions}
                                                </>
                                            );
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

IndexingTable.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(IndexingTable);
