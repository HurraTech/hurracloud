import React from 'react';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';
import LinearProgress from '@material-ui/core/LinearProgress';
import axios from 'axios';
import AddIcon from '@material-ui/icons/Add';
import Fab from '@material-ui/core/Fab';
import Grid from '@material-ui/core/Grid';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import { Typography } from '@material-ui/core';
import classNames from 'classnames';

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
            indices: []
        }
    }

    componentDidMount() {
        axios
        .get(`http://192.168.1.2:5000/indices`)
        .then(res => {
            console.log(res.data)
          this.setState({ 
              indices: res.data
           });
        });
    }

    render() {
        const { classes } = this.props;
        const { indices } = this.state
        return (
            <Grid container direction="column">
                <Grid container direction="row" spacing={32} xs={12} justify="space-between">
                    <Grid item xs={6}>
                        <Paper className={classes.root}>
                            <div className={classes.fabWrapper}>
                            <Fab aria-label="Create Index" color="secondary" className={classes.createButton}>
                                <AddIcon />
                            </Fab>
                            </div>

                            <div className={classes.tableDescriptionWrapper}>
                                <Typography variant="title" className={classes.descriptionTitle}>
                                Storage
                                </Typography>
                                <Typography variant="body" align="justify" className={classes.descriptionContent}>
                                    Your HurraCloud device comes with internal storage. You can also connect external USB devices or connect with online cloud storage such as Google Drive, Dropbox and iCloud
                                </Typography>
                            </div>
                            <Table className={classes.table}>
                                    <TableRow>
                                        <TableCell variant="head" component='div' style={{ height: "20px" }} className={classNames(classes.tableHeader)}>Media</TableCell>
                                        <TableCell variant="head" component='div' style={{ height: "20px" }}  className={classNames(classes.tableHeader)} align="right">Size</TableCell>
                                    </TableRow>
                                <TableBody>
                                    {indices.map(index => {
                                        return (
                                            <TableRow key={index.id}>
                                                <TableCell component="th" scope="row" className={classes.bodyCell}>
                                                    {index.name}
                                                </TableCell>
                                                <TableCell align="right"  className={classes.bodyCell}>{index.source.source_type}</TableCell>
                                            </TableRow>
                                        );
                                    })}
                                </TableBody>
                            </Table>
                        </Paper>
                    </Grid>
                    <Grid item xs={6}>
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
                                    <TableCell variant="head" component='div' style={{ height: "20px" }} className={classNames(classes.tableHeader)}>Index Name</TableCell>
                                    <TableCell variant="head" component='div' style={{ height: "20px" }} className={classNames(classes.tableHeader)}>Index Source</TableCell>
                                    <TableCell variant="head" component='div' style={{ height: "20px" }} className={classNames(classes.tableHeader)} align="right">Indexed Files</TableCell>
                                    <TableCell variant="head" component='div' style={{ height: "20px" }} className={classNames(classes.tableHeader)} align="right">Indexing Progress</TableCell>
                                </TableRow>
                                <TableBody>
                                    {indices.map(index => {
                                        return (
                                            <TableRow key={index.id}>
                                                <TableCell component="th" scope="row">
                                                    {index.name}
                                                </TableCell>
                                                <TableCell align="right">{index.source.source_type}</TableCell>
                                                <TableCell align="right">{index.indexed_count}</TableCell>
                                                <TableCell align="right">
                                                    <LinearProgress variant="determinate" value={(index.progress)} />
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
