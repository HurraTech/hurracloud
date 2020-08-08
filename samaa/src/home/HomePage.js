import React from 'react';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import CardMedia from '@material-ui/core/CardMedia';
import axios from 'axios';
import Grid from '@material-ui/core/Grid';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import { CardActions, SvgIcon, Typography, CardHeader, Button, ButtonBase } from '@material-ui/core'
import {Link} from 'react-router-dom';
import classNames from 'classnames';
import { fade } from '@material-ui/core/styles/colorManipulator';
import OpenIcon from '@material-ui/icons/OpenInNew'
import Chip from '@material-ui/core/Chip';
import FaceIcon from '@material-ui/icons/Face';
import RunningIcon from '@material-ui/icons/CheckCircle';
import Utils from '../utils';
import { JAWHAR_API  } from '../constants';

const styles = theme => ({
    root: {
        flexGrow: 1,
      },
      card: {
        width: 300,
        display: 'flex',
        alignItems: 'center',
        // cursor: 'pointer',
        backgroundColor: fade(theme.palette.common.white, 1),
        '&:hover': {
            backgroundColor: fade(theme.palette.common.white, 0.02),
          },

      },
      cardButton: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'left',
      },

      details: {
        display: 'flex',
        width: '100%',
        flexDirection: 'row',
        alignItems: 'center',
        justify: 'flex-start',
      },

      content: {
        display: 'block',
        textAlign: 'initial',
        width: '200px',
      },

      cover: {
        width: 151,
      },
      title: {
        fontSize: 18,
      },
      playIcon: {
        height: 38,
        width: 38,
      },

      appIcon: {
        fontSize: '68px',
        marginLeft:'10px'
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

      chip: {
        marginTop: 4,
        marginLeft: 4,
        height: 23,
        fontSize: 12,
        fontWeight: 'bold'
      },

      appDescription: {
          paddingTop: 0,
          paddingBottom: 2
      }


});


class HomePage extends React.Component {

    constructor(props, context) {
        super(props)
        this.state = {
            selectedTab: 0,
            expandedApp: '',
            apps: []
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

    componentDidMount = () => {
        this.getApplications()
    }

    getApplications = () => {
        axios
        .get(`${JAWHAR_API}/apps`)
        .then(res => {
            const response = res.data;
            this.setState({ apps: response })
        })
    };

    deleteApp = (app_id) => {
        axios
        .post(`${JAWHAR_API}/apps/${app_id}/_uninstall`)
        .then(res => {
            this.getApplications()
        })
    }

    /* ---------- Render --------- */
    render() {
        const { classes } = this.props;

        return (
            <Grid container className={classes.root} spacing={16}>
                <Grid item xs={12}>
                <Grid container className={classes.demo} justify="left" spacing={24}>
                    {this.state.apps.map(app => {
                        let icon = Utils.jsonToElement("svg", app.iconSvg)
                        return (<Grid key={app.auid} item>
                            <Card className={classes.card}>
                                    <div className={classes.cardButton}>
                                        <div className={classes.details}>
                                            <CardMedia>
                                                <SvgIcon className={classes.appIcon} color="primary" fontSize="large" viewBox={app.iconSvg["viewBox"]}>
                                                    {icon.props.children}
                                                </SvgIcon>
                                            </CardMedia>
                                            <CardContent className={classes.content}>
                                                <Typography variant="h6" className={classes.title}>{app.name}</Typography>
                                                <Chip
                                                    label="RUNNING"
                                                    icon={<RunningIcon fontSize="small" />}
                                                    className={classes.chip}
                                                    color="secondary"
                                                />

                                                <Chip
                                                    label={`v${app.version}`}
                                                    className={classes.chip}
                                                    color="primary"
                                                />

                                            </CardContent>
                                        </div>
                                        <CardContent className={classes.appDescription} >
                                            <Typography variant="subtitle2" color="textSecondary">
                                                {app.description}
                                            </Typography>
                                        </CardContent>
                                        <CardActions>

                                            <Button variant="contained" size="small" color="primary" component={Link} to={`/apps/${app.app_unique_id}`} style={{textDeocration: 'none'}}>
                                                <OpenIcon className={classNames(classes.leftIcon, classes.iconSmall)} />
                                                Open
                                            </Button>
                                            <Button variant="contained"  size="small" color="secondary">Restart</Button>
                                            <Button variant="contained"  size="small" color="secondary" onClick={() => this.deleteApp(app.app_unique_id)} >Delete</Button>
                                        </CardActions>
                                    </div>
                            </Card>
                        </Grid>)
                        })
                    }
                    {/* APP CARD BEGINS HERE
                    <Grid key="app1" item>
                        <Card className={classes.card}>
                                <div className={classes.cardButton}>
                                    <div className={classes.details}>
                                        <CardMedia>
                                            <SvgIcon className={classes.appIcon} color="primary" fontSize="large" viewBox="0 0 48 48">
                                                    <path style={{fill:"#FF9100"}} d="M 24 4 C 12.953125 4 4 12.953125 4 24 C 4 31.394531 8.023438 37.832031 13.988281 41.296875 L 18.492188 33.511719 C 15.210938 31.609375 13 28.066406 13 24 C 13 17.925781 17.925781 13 24 13 C 30.074219 13 35 17.925781 35 24 C 35 28.066406 32.789063 31.609375 29.507813 33.511719 L 34.011719 41.296875 C 39.976563 37.832031 44 31.394531 44 24 C 44 12.953125 35.046875 4 24 4 Z "/>
                                                    <path style={{fill:"#1A237E"}} d="M 30 24 C 30 20.6875 27.3125 18 24 18 C 20.6875 18 18 20.6875 18 24 C 18 26.554688 19.601563 28.734375 21.851563 29.597656 L 19.292969 43.417969 C 20.804688 43.785156 22.375 44 24 44 C 25.625 44 27.195313 43.785156 28.707031 43.421875 L 26.148438 29.597656 C 28.398438 28.734375 30 26.554688 30 24 Z "/>
                                            </SvgIcon>
                                        </CardMedia>
                                        <CardContent className={classes.content}>
                                            <Typography variant="h6" className={classes.title}>OpenVPN</Typography>
                                            <Chip
                                                label="RUNNING"
                                                icon={<RunningIcon fontSize="small" />}
                                                className={classes.chip}
                                                color="secondary"
                                            />

                                            <Chip
                                                label="v1.2.3"
                                                className={classes.chip}
                                                color="primary"
                                            />

                                        </CardContent>
                                    </div>
                                    <CardContent className={classes.appDescription} >
                                        <Typography variant="subtitle2" color="textSecondary">
                                            Allows you to securely access your HurraCloud Device remotely from anywhere using Internet-connected smartphone or computer
                                        </Typography>
                                    </CardContent>
                                    <CardActions>

                                        <Button variant="contained" size="small" color="primary" component={Link} to={`/apps/openvpn`} style={{textDeocration: 'none'}}>
                                            <OpenIcon className={classNames(classes.leftIcon, classes.iconSmall)} />
                                            Open
                                        </Button>
                                        <Button variant="contained"  size="small" color="secondary">Restart</Button>
                                        <Button variant="contained"  size="small" color="secondary">Delete</Button>
                                    </CardActions>
                                </div>
                        </Card>
                    </Grid>

                    <Grid key="app1" item>
                        <Card className={classes.card}>
                                <div className={classes.cardButton}>
                                    <div className={classes.details}>
                                        <CardMedia>
                                            <SvgIcon className={classes.appIcon} color="primary" fontSize="large" viewBox="-525.656 -459.391 4103.18 2339.532">
                                                <path fill="#494949" d="M-525.656-459.391h4103.18v2339.532h-4103.18z"/>
                                                <path fill="#FFF" d="M3068.929 210.125h-290.001l-289.999 500 289.999 500h289.748l-289.748-499.75 290.001-500.25"/><radialGradient id="a" cx="1244.322" cy="919.871" r=".925" gradientTransform="matrix(610 0 0 -1000.5 -756323.625 921038.75)" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#f9be03"/><stop offset="1" stop-color="#cc7c19"/></radialGradient>
                                                <path fill="url(#a)" d="M2168.94 210.125h290l320 500.25-320 500.25h-290l319.999-500.25-319.999-500.25"/>
                                                <path fill="#FFF" d="M2068.886 1210.125h-577.073v-1000h577.073v173.737h-364.607v219.562h339.255v173.731h-339.255v257.864h364.607v175.106M774.215 1210.125v-1000h212.04v824.895h405.609v175.105H774.215M572.886 768.949c-67.268 57.007-162.91 85.501-286.938 85.501H194.98v355.675H-17.06V680.463l290 .359c177.562-2.069 186.842-110.818 186.842-148.497 0-34.979 0-146.755-157.842-148.5l-319 .003V210.125h319.424c121.293 0 213.515 26.107 276.677 78.321 63.152 52.213 94.733 130.071 94.733 233.581 0 107.624-33.633 189.928-100.888 246.922z"/>
                                                <path fill="#FFF" d="M-17.06 320.125h212.2v429h-212.2z"/>
                                            </SvgIcon>
                                        </CardMedia>
                                        <CardContent className={classes.content}>
                                            <Typography variant="h6" className={classes.title}>Plex Media Server</Typography>
                                            <Chip
                                                label="RUNNING"
                                                icon={<RunningIcon fontSize="small" />}
                                                className={classes.chip}
                                                color="secondary"
                                            />

                                            <Chip
                                                label="v1.2.3"
                                                className={classes.chip}
                                                color="primary"
                                            />

                                        </CardContent>
                                    </div>
                                    <CardContent className={classes.appDescription} >
                                        <Typography variant="subtitle2" color="textSecondary">
                                            Allows you to securely access your HurraCloud Device remotely from anywhere using Internet-connected smartphone or computer
                                        </Typography>
                                    </CardContent>
                                    <CardActions>
                                        <Button variant="contained" size="small" color="primary" component={Link} to={`/apps/openvpn`} style={{textDeocration: 'none'}}>
                                            <OpenIcon className={classNames(classes.leftIcon, classes.iconSmall)} />
                                            Open
                                        </Button>
                                        <Button variant="contained"  size="small" color="secondary">Restart</Button>
                                        <Button variant="contained"  size="small" color="secondary">Delete</Button>
                                    </CardActions>
                                </div>
                        </Card>
                    </Grid>
                    */}


                </Grid>
            </Grid>
        </Grid>
        );
    }

}

HomePage.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(HomePage);
