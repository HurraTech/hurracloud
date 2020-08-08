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
import Iframe from 'react-iframe';
import { JAWHAR_API, APP_RUNNER_HOSTNAME } from '../constants';

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


class AppLoader extends React.Component {

    constructor(props, context) {
        super(props)
        console.log(props)
        this.state = {
            port: 0,
            auid: props.auid,
        }
    }

    componentDidMount = () => {
      axios
      .get(`${JAWHAR_API}/apps/${this.state.auid}`)
      .then(res => {
          const response = res.data;
          this.setState({ port: response.deployment_port })
      })

    }


    /* ---------- Render --------- */
    render() {
        const { classes } = this.props;
        return (
            <Iframe
            url={`${APP_RUNNER_HOSTNAME}:${this.state.port}`}
            width="100%"
            height="100vh"
            display="initial"
            align="center"
            position="relative"
            allowFullScreen
          />
        );
    }

}

AppLoader.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(AppLoader);
