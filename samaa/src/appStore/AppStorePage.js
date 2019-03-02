import React from 'react';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';
import axios from 'axios';
import Grid from '@material-ui/core/Grid';
import { Typography, DialogContent, DialogActions, DialogContentText, InputBase, List, ListItem, Avatar, SvgIcon, ListItemText, Divider } from '@material-ui/core';
import MuiExpansionPanel from '@material-ui/core/ExpansionPanel';
import MuiExpansionPanelSummary from '@material-ui/core/ExpansionPanelSummary';
import MuiExpansionPanelDetails from '@material-ui/core/ExpansionPanelDetails';

import { fade } from '@material-ui/core/styles/colorManipulator';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import classNames from 'classnames';
import Tabs from '@material-ui/core/Tabs';
import Tab from '@material-ui/core/Tab';
import AppBar from '@material-ui/core/AppBar';
import SearchIcon from '@material-ui/icons/Search';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';

const styles = theme => ({
    root: {
        width: '100%',
        marginTop: theme.spacing.unit * 3,
        overflowX: 'auto',
    },

    inputRoot: {
        color: 'inherit',
        width: '100%',
      },

    inputInput: {
        paddingTop: theme.spacing.unit,
        paddingRight: theme.spacing.unit * 4,
        paddingBottom: theme.spacing.unit,
        paddingLeft: theme.spacing.unit * 8,
        transition: theme.transitions.create('width'),
        width: '100%',
        color: 'black',
        [theme.breakpoints.up('md')]: {
            width: 200,
        },
    },

    search: {
        position: 'absolute',
        borderRadius: theme.shape.borderRadius,
        backgroundColor: fade(theme.palette.common.white, 0.15),
        '&:hover': {
          backgroundColor: fade(theme.palette.common.white, 0.5),
        },
        borderColor: fade(theme.palette.common.black, 0.15),
        borderWidth: '1px',
        borderStyle: 'solid',
        marginLeft: 0,
        right: 10,
        marginRight: 0,
        paddingRight: 0,
        top: theme.spacing.unit * 0.5,
        [theme.breakpoints.up('sm')]: {
          width: 'auto',
        },
    },

    searchIcon: {
        width: theme.spacing.unit * 9,
        height: '100%',
        position: 'absolute',
        pointerEvents: 'none',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
    },
    
    appMetadataContainer: {
        // padding: 15
    },
    appRow: {
        '&:hover': {
            backgroundColor: fade(theme.palette.common.white, 0.5),
          }  
    },

    icon: {
        // margin: theme.spacing.unit * 2,
        fontSize: '56px',
        // overflow: 'visible'
    },

    appMetadataLabelCell: {
        width: '180px'
    },

    appMetadataTable: {
        color: 'black',
    },

    heading: {
        fontSize: theme.typography.pxToRem(15),
        flexBasis: '33.33%',
        flexShrink: 0,
        color: theme.palette.text.secondary,
    },

    secondaryHeading: {
    fontSize: theme.typography.pxToRem(15),
    },
        
});



const ExpansionPanel = withStyles({
    root: {
      border: '1px solid rgba(0,0,0,.125)',
      boxShadow: 'none',
      '&:not(:last-child)': {
        borderBottom: 0,
      },
      '&:before': {
        display: 'none',
      },
    },
    expanded: {
      margin: 'auto',
    },
  })(MuiExpansionPanel);
  
const ExpansionPanelSummary = withStyles({
    root: {
        backgroundColor: 'rgba(0,0,0,.00)',
        borderBottom: '1px solid rgba(0,0,0,.125)',
        marginBottom: -1,
        minHeight: 56,
        '&$expanded': {
            backgroundColor: 'rgba(0,0,0,.039)',
            minHeight: 56,
        },
    },
    content: {
        '&$expanded': {
        margin: '12px 0',
        },
    },
    expanded: {},
})(props => <MuiExpansionPanelSummary {...props} />);

ExpansionPanelSummary.muiName = 'ExpansionPanelSummary';
  
const ExpansionPanelDetails = withStyles(theme => ({
    root: {
      padding: theme.spacing.unit * 2,
      backgroundColor: 'rgba(0,0,0,.009)'
    },
}))(MuiExpansionPanelDetails);
   
class AppStorePage extends React.Component {

    constructor(props, context) {
        super(props)
        this.state = {
            selectedTab: 0,
            expandedApp: '',
        }
    }

    expandApp = appName => (event, expanded) => {
        this.setState({
            expandedApp: expanded ? appName : false,
        });
      };
        
    changeTab = (event, selectedTab) => {
        this.setState({ selectedTab });
      };
    
    /* ---------- Render --------- */
    render() {
        const { classes } = this.props;
        const { selectedTab, expandedApp } = this.state
        return (
            <div>
            <AppBar position="static" color="default">
                <Tabs
                    value={selectedTab}
                    onChange={this.changeTab}
                    scrollButtons="on"
                    indicatorColor="primary"
                    textColor="primary"
                    className={classes.tabsPanel}
                >
                    <Tab label="Store" />
                    <Tab label="Installed" />
                    <Tab label="Updates" />

                    <div className={classes.search}>
                    <div className={classes.searchIcon}>
                        <SearchIcon />
                    </div>
                    <InputBase
                        placeholder="Search App Store"
                        onKeyPress={this.onSearchBarKeyPress}
                        classes={{
                        root: classes.inputRoot,
                        input: classes.inputInput,
                        }}
                    />
                </div>

                </Tabs>
            </AppBar>
            {selectedTab === 0 && <Paper square={true}>
                    <ExpansionPanel expanded={expandedApp === 'openvpn'} onChange={this.expandApp('openvpn')}>
                        <ExpansionPanelSummary expandIcon={<ExpandMoreIcon />}>
                            <List>
                                <ListItem>
                                    <SvgIcon className={classes.icon} color="primary" fontSize="large" viewBox="0 0 48 48">
                                        <path style={{fill:"#FF9100"}} d="M 24 4 C 12.953125 4 4 12.953125 4 24 C 4 31.394531 8.023438 37.832031 13.988281 41.296875 L 18.492188 33.511719 C 15.210938 31.609375 13 28.066406 13 24 C 13 17.925781 17.925781 13 24 13 C 30.074219 13 35 17.925781 35 24 C 35 28.066406 32.789063 31.609375 29.507813 33.511719 L 34.011719 41.296875 C 39.976563 37.832031 44 31.394531 44 24 C 44 12.953125 35.046875 4 24 4 Z "/>
                                        <path style={{fill:"#1A237E"}} d="M 30 24 C 30 20.6875 27.3125 18 24 18 C 20.6875 18 18 20.6875 18 24 C 18 26.554688 19.601563 28.734375 21.851563 29.597656 L 19.292969 43.417969 C 20.804688 43.785156 22.375 44 24 44 C 25.625 44 27.195313 43.785156 28.707031 43.421875 L 26.148438 29.597656 C 28.398438 28.734375 30 26.554688 30 24 Z "/>
                                    </SvgIcon>
                                    <ListItemText primary="OpenVPN Server"
                                            secondary="Allows you to securely access your HurraCloud device and applications remotely from anywhere (requires internet connection)"
                                    />
                                </ListItem>
                            </List>
                        </ExpansionPanelSummary>
                        <ExpansionPanelDetails>
                            <List dense={true}>
                                <ListItem>
                                    We received best app of the year for year 2019!!! 
                                </ListItem>
                                <ListItem>
                                    <Typography className={classes.heading}>Publisher</Typography>
                                    <Typography className={classes.secondaryHeading}>HurraNet LLC</Typography>
                                </ListItem>
                                <ListItem>
                                    <Typography className={classes.heading}>Published Date</Typography>
                                    <Typography className={classes.secondaryHeading}>March 1st, 2019</Typography>
                                </ListItem>
                            </List>
                        </ExpansionPanelDetails>
                    </ExpansionPanel>

                    <ExpansionPanel expanded={expandedApp === 'openvpn2'} onChange={this.expandApp('openvpn2')}>
                        <ExpansionPanelSummary expandIcon={<ExpandMoreIcon />}>
                            <List>
                                <ListItem>
                                    <SvgIcon className={classes.icon} color="primary" fontSize="large" viewBox="-525.656 -459.391 4103.18 2339.532">
                                        <path fill="#494949" d="M-525.656-459.391h4103.18v2339.532h-4103.18z"/>
                                        <path fill="#FFF" d="M3068.929 210.125h-290.001l-289.999 500 289.999 500h289.748l-289.748-499.75 290.001-500.25"/><radialGradient id="a" cx="1244.322" cy="919.871" r=".925" gradientTransform="matrix(610 0 0 -1000.5 -756323.625 921038.75)" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#f9be03"/><stop offset="1" stop-color="#cc7c19"/></radialGradient>
                                        <path fill="url(#a)" d="M2168.94 210.125h290l320 500.25-320 500.25h-290l319.999-500.25-319.999-500.25"/>
                                        <path fill="#FFF" d="M2068.886 1210.125h-577.073v-1000h577.073v173.737h-364.607v219.562h339.255v173.731h-339.255v257.864h364.607v175.106M774.215 1210.125v-1000h212.04v824.895h405.609v175.105H774.215M572.886 768.949c-67.268 57.007-162.91 85.501-286.938 85.501H194.98v355.675H-17.06V680.463l290 .359c177.562-2.069 186.842-110.818 186.842-148.497 0-34.979 0-146.755-157.842-148.5l-319 .003V210.125h319.424c121.293 0 213.515 26.107 276.677 78.321 63.152 52.213 94.733 130.071 94.733 233.581 0 107.624-33.633 189.928-100.888 246.922z"/>
                                        <path fill="#FFF" d="M-17.06 320.125h212.2v429h-212.2z"/>

                                    </SvgIcon>
                                    <ListItemText primary="Plex Media Server"
                                            secondary="Stream videos and photos on your HurraCloud Drive to your mobile device or Wi-Fi connected TV."
                                    />
                                </ListItem>
                            </List>
                        </ExpansionPanelSummary>
                        <ExpansionPanelDetails>
                            <List dense={true}>
                                <ListItem>
                                    We received best app of the year for year 2019!!! 
                                </ListItem>
                                <ListItem>
                                    <Typography className={classes.heading}>Publisher</Typography>
                                    <Typography className={classes.secondaryHeading}>HurraNet LLC</Typography>
                                </ListItem>
                                <ListItem>
                                    <Typography className={classes.heading}>Published Date</Typography>
                                    <Typography className={classes.secondaryHeading}>March 1st, 2019</Typography>
                                </ListItem>
                            </List>
                        </ExpansionPanelDetails>
                    </ExpansionPanel>


                </Paper>
            }
                {/* // <Grid container direction="column">
                //     <Grid container direction="row" spacing={32} xs={12} justify="space-between">
                //     <Grid item xs={12}>
                //             <Paper className={classes.root}>
                //                 <div className={classes.tableDescriptionWrapper}>
                //                     <Typography variant="title" className={classes.descriptionTitle}>
                //                     Storage Indexes
                //                     </Typography>
                //                     <Typography variant="body" align="justify" className={classes.descriptionContent}>
                //                         Your HurraCloud device comes with internal storage. You can also connect external USB devices or connect with online cloud storage such as Google Drive, Dropbox and iCloud
                //                     </Typography>
                //                 </div>
                //                 <Table className={classes.table}>
                //                     <TableHead>
                //                         <TableRow>
                //                             <TableCell variant="head" component='div' className={classNames(classes.tableHeader, classes.iconCell)} scope="row"></TableCell>
                //                         </TableRow>
                //                     </TableHead>
                //                     <TableBody>
                //                         <TableRow className={classes.sourceRow}>
                //                             <TableCell scope="row" className={classes.iconCell}>
                //                             </TableCell>
                //                         </TableRow>
                //                     </TableBody>
                //                 </Table>
                //             </Paper>
                //         </Grid>                
                //     </Grid>
                // </Grid> */}
            </div>
            );
    }
        
}

AppStorePage.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(AppStorePage);
