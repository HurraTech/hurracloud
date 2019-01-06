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

    tableHeader: {
        backgroundColor: theme.palette.grey[900],
        color: 'white',
        height: '32px',
        fontSize: '11pt'
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
        // width: '100%',
        padding: 'relative',
        float: 'right',
        marginTop: '-25px',
        marginRight: '35px',
        zIndex: 999

    },

    createButton: {
        position: 'absolute',
        zIndex: 999,
        marginRight: '-10px',
        // left: '650px',
        // top: '10px'
    },

    tableCell: {
        fontSize: '2em'
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
            sources: []
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

    componentDidMount() {
        axios
        .get(`http://192.168.1.2:5000/indices`)
        .then(res => {
          this.setState({ 
              indices: res.data
           }, () => {
            $(document).ready(function() {
                $(".meter > span").each(function() {
                    $(this)
                        .data("origWidth", $(this).width())
                        .width(0)
                        .animate({
                            width: `${$(this).data("origWidth")}%`
                        }, 1200, () => {
                            if ($(this).data("origWidth") == 100)
                                $(this).parent().hide(0, () => { console.log($(this).siblings()); $(this).parent().siblings(".indexingDone").css('display', 'block') } )
                        })
                });
            });
                
           });
        });

        axios
        .get(`http://192.168.1.2:5000/sources`)
        .then(res => {
          this.setState({ 
              sources: res.data
           });
        });        


    }

    render() {
        const { classes } = this.props;
        const { indices, sources } = this.state
        return (
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
                                Attached Drives & Accounts
                                </Typography>
                                <Typography variant="body" align="justify" className={classes.descriptionContent}>
                                    Your HurraCloud device comes with internal storage. You can also connect external USB devices or connect with online cloud storage such as Google Drive, Dropbox and iCloud
                                </Typography>
                            </div>
                            <Table className={classes.table}>
                                    <TableRow>
                                        <TableCell variant="head" component='div' style={{ height: "20px" }} className={classNames(classes.tableHeader)}>Name</TableCell>
                                        <TableCell variant="head" component='div' style={{ height: "20px" }}  className={classNames(classes.tableHeader)} align="left">Capacity</TableCell>
                                        <TableCell variant="head" component='div' style={{ height: "20px" }}  className={classNames(classes.tableHeader)} align="left">Free Space</TableCell>
                                        <TableCell variant="head" component='div' style={{ height: "20px" }}  className={classNames(classes.tableHeader)} align="left">Type</TableCell>
                                    </TableRow>
                                <TableBody>
                                    {sources.map(source => {
                                        let icon_class = "fab fa-usb"
                                        if (source.source_type == "system")
                                            icon_class = "fas fa-database"
                                        else if (source.source_type == "internal")
                                            icon_class = "fab fa-hdd"
                                        let partitions = [];
                                        let all_mounted = source.metadata.partitions.reduce((all_mounted, partition) => all_mounted && partition.mounted, true)
                                        let total_free = source.metadata.partitions.reduce((sum, partition) => sum + (partition.available||0), 0)
                                        if (source.source_type != "system")
                                            partitions = source.metadata.partitions.map((partition,index) =>{
                                                let partition_name = partition.LABEL || partition.PARTLABEL || `Partition ${index}`
                                                return (<TableRow key={source.id}>
                                                    <TableCell scope="row" className={classes.bodyCell}>
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                    {partition.mounted ? partition_name : <i>{partition_name}</i>}
                                                    
                                                    </TableCell>
                                                    <TableCell scope="row" className={classes.bodyCell}>
                                                    {partition.mounted && Utils.humanFileSize(partition.size)}
                                                    </TableCell>
                                                    <TableCell scope="row" className={classes.bodyCell}>
                                                    {partition.mounted && Utils.humanFileSize(partition.available)}
                                                    </TableCell>
                                                    <TableCell align="left"  className={classes.bodyCell}>
                                                    </TableCell>                                                
                                                </TableRow>)
                                            })
                                        return (
                                            <>
                                            <TableRow key={source.id}>
                                                <TableCell scope="row" className={classes.bodyCell}>
                                                <div style={{float:'left'}}><span
                                                className={`${icon_class}`}
                                                style={{ marginRight: '0.5em' }}
                                                 />
                                                 </div> 
                                                {source.source_type == "system" ? <span style={{fontWeight:500}}>System</span> : source.name}
                                                </TableCell>
                                                <TableCell scope="row" className={classes.bodyCell}>
                                                {Utils.humanFileSize(source.capacity*1024)}
                                                </TableCell>
                                                <TableCell>{(source.source_type == "system" || source.source_type == "internal_storage" || all_mounted) 
                                                                && Utils.humanFileSize(total_free*1024)}</TableCell>
                                                <TableCell align="left"  className={classes.bodyCell}>
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
                    <Grid item xs={12}>
                        <Paper className={classes.root}>
                            <div className={classes.fabWrapper}>
                                <Fab aria-label="Create Index" color="secondary" className={classes.createButton}>
                                    <AddIcon />
                                </Fab>
                                </div>


                            <div className={classes.tableDescriptionWrapper}>
                                <Typography variant="title" className={classes.descriptionTitle}>
                                Indexes
                                </Typography>
                                <Typography variant="body" align="justify" className={classes.descriptionContent}>
                                    Indexes make your files and data searchable in blazing speed. They take a while to build for the first time, but they are worth it. We promise!
                                </Typography>
                            </div>                        
                            <Table className={classes.table}>
                                <TableRow>
                                    <TableCell variant="head" component='div' style={{ height: "20px" }} className={classNames(classes.tableHeader)}>Name</TableCell>
                                    <TableCell variant="head" component='div' style={{ height: "20px" }} className={classNames(classes.tableHeader)}>Data Source</TableCell>
                                    <TableCell variant="head" component='div' style={{ height: "20px" }} className={classNames(classes.tableHeader)} align="right">Indexed Files</TableCell>
                                    <TableCell variant="head" component='div' style={{ height: "20px" }} className={classNames(classes.tableHeader)} align="right">Status</TableCell>
                                </TableRow>
                                <TableBody>
                                    {indices.map(index => {
                                        return (
                                            <TableRow key={index.id}>
                                                <TableCell align="left" className={classes.tableCell}>{index.name}</TableCell>
                                                <TableCell scope="row" className={classes.tableCell}>
                                                <div style={{float:'left'}}><span
                                                className={'fab fa-usb fa-2x'}
                                                style={{ marginRight: '0.5em' }}
                                                 />
                                                 </div>
                                                 <div style={{paddingTop:'6px'}}>
                                                {index.name}
                                                </div>
                                                </TableCell>
                                                <TableCell align="right" className={classes.tableCell}>{index.indexed_count}</TableCell>
                                                <TableCell align="right" className={classes.tableCell}>
                                                    { index.progress < 100 && (<div>
                                                    <div className="meter orange">
                                                        <span style={{width: index.progress }}>
                                                        </span>
                                                    </div>
                                                    <div className="indexingDone">
                                                        <i style={{fontSize: 16, color: 'green'}} class="fas fa-check-circle"></i>
                                                    </div></div>)}
                                                    { index.progress >= 100 && (<div>
                                                        <i style={{fontSize: 16, color: 'green'}} class="fas fa-check-circle"></i>
                                                    </div>)}                                                    
                                                </TableCell>
                                            </TableRow>
                                        );
                                    })}
                                </TableBody>
                            </Table>
                        </Paper>                        
                    </Grid>
                </Grid>
            </Grid>
            );
    }
        
}

IndexingTable.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(IndexingTable);
