import React from 'react';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import CardMedia from '@material-ui/core/CardMedia';
import axios from 'axios';
import Grid from '@material-ui/core/Grid';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import { CardActions, SvgIcon, Typography, CardHeader, Button, ButtonBase, Select, MenuItem, List, ListItem } from '@material-ui/core'
import {Link} from 'react-router-dom';
import classNames from 'classnames';
import { fade } from '@material-ui/core/styles/colorManipulator';
import OpenIcon from '@material-ui/icons/OpenInNew'
import Chip from '@material-ui/core/Chip';
import CircularProgress from '@material-ui/core/CircularProgress';
import FaceIcon from '@material-ui/icons/Face';
import RunningIcon from '@material-ui/icons/CheckCircle';
import Utils from '../utils';
import {Pie, HorizontalBar} from 'react-chartjs-2';
import { JAWHAR_API  } from '../constants';


const styles = theme => ({
    root: {
        flexGrow: 1,
      },
      card: {
        width: 300,
        height: "100%",
        display: 'flex',
        alignItems: 'center',
        position: 'relative',
        // cursor: 'pointer',
        backgroundColor: fade(theme.palette.common.white, 1),
        '&:hover': {
            backgroundColor: fade(theme.palette.common.white, 0.02),
          },

      },

      chartCard: {
          height: "100%",
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
      dashboardHeading: {
        fontSize: 20,
        fontWeight: 'bold'
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
      },

    appLoading: {
        width: '100%',
        height: '100%',
        position: 'absolute',
        backgroundColor: 'white',
        opacity: '0.5',
        top: 0,
        left: 0,
        paddingLeft: '130px',
        paddingTop: '70px',
        zIndex: 10,
    },

    indexChartTitle: {
        fontSize: 17,
        height: '100%',
        color: '#5c5c5c',
        paddingTop: "15px",
        textAlign: "center"
    },

    progress: {
        color: 'black'
    },

    selectDeviceGridItem: {
		margin: 'auto'
    },

    heading: {
        fontSize: theme.typography.pxToRem(15),
        color: theme.palette.text.secondary,
        width: "200px"
    },

    secondaryHeading: {
    	fontSize: theme.typography.pxToRem(15),
    },

    noAppsMessage: {
        textAlign: 'center'
    }

});


class HomePage extends React.Component {

    constructor(props, context) {
        super(props)
        this.state = {
            selectedTab: 0,
            expandedApp: '',
            apps: this.props.apps || [],
            sources: this.props.sources || [],
            capacityChartData: this.buildChartDataset(this.props.sources),
            indexChartData: this.buildIndexChartDataset(this.props.sources),
            selectedChartSource: null,
			stats : {
				cpu_load: 1.06,
				total_memory: 15.39,
				free_memory: 1.602,
				disk_stats: {
					reads_per_second: 0,
					writes_per_second: 0,
					total_bytes_read: 0,
					total_bytes_written: 0
				}
			}
        }
    }

    buildIndexChartDataset(sources) {
      var indexedSources = sources.filter(s => s.index !== null);
      var sourceNames = indexedSources.map(s => s.name)
      var indexSizes = indexedSources.map(s => Utils.humanFileSizeMBRaw(s.index.size))

      const data = {
          labels: sourceNames,
          datasets: [
              {
                        label: 'Index Size (MB)',
                        backgroundColor: '#36A2EB',
                        backgrounColor: '#91d3ff',
                        borderWidth: 0,
                        hoverBackgroundColor: '#91d3ff',
                        data: indexSizes
              }

          ]

      };
      return data

    }

    buildChartDataset(sources, select=null) {
	    var dataset =  {
          labels: [
         		'Data (GB)',
         		'Free Space (GB)',
          ],
          datasets: [{
	      	data: [0,0],
          	backgroundColor: [
          	'#FF6384',
          	'#36A2EB',
            '#792333'
          	],
          	hoverBackgroundColor: [
          	'#FF6384',
          	'#36A2EB',
            '#792333'
          	]
          }]
         }
        let source = sources[0]
        if (select != null) {
            source = sources.filter(s => s.id == select)
            if (source.length > 0) source = source[0]
        }
        if (source !== null && source != undefined) {
	       dataset.datasets[0].data = [Utils.humanFileSizeGBRaw(source.used), Utils.humanFileSizeGBRaw(source.free)]
           if (source.sourcable.drive_type == "internal")
           {
              var indexedSources = sources.filter(s => s.index !== null);
              var indexSizes = indexedSources.map(s => Utils.humanFileSizeGBRaw(s.index.size))
              var totalIndexSize = indexSizes.reduce((a,b) => parseInt(a)+ parseInt(b), 0)
              dataset.labels.push("Indices Data (GB)")
              dataset.datasets[0].data.push(totalIndexSize)
            }
        }

        return dataset
    }

	changeChartStorage = (selectedSource) => {
		this.setState({
            capacityChartData: this.buildChartDataset(this.props.sources, selectedSource),
            selectedChartSource: selectedSource,
		});
	}

    componentDidUpdate = (prevProps, prevState, snapshot) => {
      if (JSON.stringify(this.props.apps) != JSON.stringify(prevProps.apps)) {
            this.setState({
                apps: this.props.apps
            }, () => {
                this.forceUpdate()
            })
        }

       if (JSON.stringify(this.props.sources) != JSON.stringify(prevProps.sources)) {
           // figure out default selected source id
           let selectedChartSource = this.state.selectedChartSource
           if (this.state.selectedChartSource == null) {
               selectedChartSource = this.props.sources[0].id
		   }
            this.setState({
                sources: this.props.sources,
                capacityChartData: this.buildChartDataset(this.props.sources, selectedChartSource),
                indexChartData: this.buildIndexChartDataset(this.props.sources),
                selectedChartSource: selectedChartSource,
            }, () => {
                this.forceUpdate()
            })
        }

		if (JSON.stringify(this.props.stats) != JSON.stringify(prevProps.stats)) {
            this.setState({
                stats: this.props.stats,
            }, () => {
                this.forceUpdate()
            })
        }
    }
    handleChange = prop => event => {
      this.setState({ [prop]: event.target.value });
    };

    expandApp = appName => (event, expanded) => {
        this.setState({
            expandedApp: expanded ? appName : false,
        });
      };

    changeTab = (event, selectedTab) => {
        this.setState({ selectedTab });
    };

    componentDidMount = () => {
         if (this.state.selectedChartSource == null && this.props.sources.length > 0) {
             this.setState({selectedChartSource: this.props.sources[0].id})
		 }
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
        var currentApps = [...this.state.apps]
        currentApps.find(a => a.app_unique_id === app_id).status = "deleting"
        this.setState({apps: currentApps}, () => {
          axios
           .post(`${JAWHAR_API}/apps/${app_id}/_uninstall`)
           .then(res => {
               this.getApplications()
           })
        })
    }

    /* ---------- Render --------- */
    render() {
        const { classes } = this.props;

        return (
            <Grid container className={classes.root} spacing={2} alignItems="stretch">
                <Grid item xs={12}>
                    <Typography variant="h6" className={classes.dashboardHeading}>Dashboard</Typography>
                </Grid>
                <Grid item xs={3}>
                    <Card className={classes.chartCard}>
                      <CardContent>
                        <Grid container spacing={2}>
				         	<Grid item xs={12}>
                               <Typography variant="h4" className={classes.dashboardHeading}>System Stats</Typography><br/>
				         	</Grid>
				         	<Grid item xs={12} >
                            <List>
                                <ListItem>
                                    <Typography className={classes.heading}>CPU Load Average</Typography>
                                    <Typography className={classes.secondaryHeading}>{this.state.stats["cpu_load"]}</Typography>
                                </ListItem>
                                <ListItem>
                                    <Typography className={classes.heading}>Total Memory</Typography>
                                    <Typography className={classes.secondaryHeading}>{Utils.humanFileSize(1024 * 1024 * 1024 * this.state.stats["total_memory"])}</Typography>
                                </ListItem>
                                <ListItem>
                                    <Typography className={classes.heading}>Free Memory</Typography>
                                    <Typography className={classes.secondaryHeading}>{Utils.humanFileSize(1024 * 1024 * 1024 * this.state.stats["free_memory"])}</Typography>
                                </ListItem>
                                <ListItem>
                                    <Typography className={classes.heading}>Storage Reads/Second</Typography>
                                    <Typography className={classes.secondaryHeading}>{Utils.humanFileSize(1024 * this.state.stats["disk_stats"]["reads_per_second"])}/second</Typography>
                                </ListItem>
                                <ListItem>
                                    <Typography className={classes.heading}>Storage Writes/Second</Typography>
                                    <Typography className={classes.secondaryHeading}>{Utils.humanFileSize(1024 * this.state.stats["disk_stats"]["writes_per_second"])}/second</Typography>
                                </ListItem>
                                <ListItem>
                                    <Typography className={classes.heading}>Storage Total Reads</Typography>
                                    <Typography className={classes.secondaryHeading}>{Utils.humanFileSize(1024 * this.state.stats["disk_stats"]["total_bytes_read"])}</Typography>
                                </ListItem>
                                <ListItem>
                                    <Typography className={classes.heading}>Storage Total Writes</Typography>
                                    <Typography className={classes.secondaryHeading}>{Utils.humanFileSize(1024 * this.state.stats["disk_stats"]["total_bytes_written"])}</Typography>
                                </ListItem>
                            </List>
				         	</Grid>
				     	</Grid>
				    </CardContent>
                  </Card>
                </Grid>
                <Grid item xs={4}>
                    <Card className={classes.chartCard}>
                      <CardContent>
                        <Grid container spacing={2}>
				         	<Grid item xs={12}>
                               <Typography variant="h4" className={classes.dashboardHeading}>Storage Usage</Typography><br/>
				               <Pie data={this.state.capacityChartData} width="180" height="180"   options={{ maintainAspectRatio: false }} />
				         	</Grid>
				         	<Grid item xs={12} className={classes.selectDeviceGridItem}>
							  <Select value={this.state.selectedChartSource}  onChange={(event) => this.changeChartStorage(event.target.value) }>
                      			{this.state.sources.filter(s => s.status == "mounted").map((source, index) => {
									return (
	                               	 <MenuItem value={source.id} >{source.name}</MenuItem>)
									})
							    }
        					  </Select>
				         	</Grid>
				     	</Grid>
				    </CardContent>
                  </Card>
                </Grid>
                <Grid item xs={5}>
                    <Card className={classes.chartCard}>
                      <CardContent>
                        <Grid container spacing={2}>
				         	<Grid item xs={12}>
                               <Typography variant="h4" className={classes.dashboardHeading}>Index Storage Usage</Typography><br/>
				               <HorizontalBar data={this.state.indexChartData} width="180" height="180"   options={{ maintainAspectRatio: false }} />
				         	</Grid>
				     	</Grid>
				        <Grid item xs={12} className={classes.selectDeviceGridItem}>
                            <Typography variant="subtitle" component="div" className={classes.indexChartTitle} >Storage Usage of Indices</Typography>
                        </Grid>
				    </CardContent>
                  </Card>
                </Grid>
                <Grid container item xs={12} spacing={2}>
                    <Grid item xs={12}>
                        <Typography variant="h6" className={classes.dashboardHeading}>Applications</Typography>
                    </Grid>
                    { this.state.apps.length == 0 &&
                        <Grid item xs={12}>
                            <Typography variant="h6" component="div" className={classes.noAppsMessage}>You do not have any installed applications. Visit the App Store to install applications.</Typography>
                        </Grid> }
                      {this.state.apps.map(app => { return (
                          <Grid key={app.auid} item>
                              <Card className={classes.card}>
                                      {app.status != "started" &&
                                          <div className ={classes.appLoading} >
                                              <CircularProgress className={classes.progress} />
                                          </div>}
                                      <div className={classes.cardButton}>
                                          <div className={classes.details}>
                                              <CardMedia dangerouslySetInnerHTML={{__html: app.iconSvg}} />
                                              <CardContent className={classes.content}>
                                                  <Typography variant="h6" className={classes.title}>{app.name}</Typography>

                                              </CardContent>
                                          </div>
                                          <CardContent className={classes.appDescription} >
                                              <Typography variant="subtitle2" color="textSecondary">
                                                  {app.description}
                                              </Typography>
                                          </CardContent>
                                          <CardActions>
                                              <Button variant="contained" size="small" color="primary" component={Link} to={`/apps/${app.app_unique_id}`} style={{textDeocration: 'none'}}>
                                              <OpenIcon className={classNames(classes.leftIcon, classes.iconSmall)} disabled={true} />
                                                  Open
                                              </Button>
                                              <Button variant="contained"  size="small" color="secondary" onClick={() => this.deleteApp(app.app_unique_id)} >Delete</Button>
                                          </CardActions>
                                      </div>
                              </Card>
                          </Grid>)
                        })
                      }
            </Grid>
        </Grid>
        );
    }

}

HomePage.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(HomePage);
