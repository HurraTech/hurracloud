import React from 'react';
import PropTypes from 'prop-types';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import IconButton from '@material-ui/core/IconButton';
import Typography from '@material-ui/core/Typography';
import InputBase from '@material-ui/core/InputBase';
import Badge from '@material-ui/core/Badge';
import MenuItem from '@material-ui/core/MenuItem';
import Menu from '@material-ui/core/Menu';
import { fade } from '@material-ui/core/styles/colorManipulator';
import { withStyles } from '@material-ui/core/styles';
import MenuIcon from '@material-ui/icons/Menu';
import SearchIcon from '@material-ui/icons/Search';
import AccountCircle from '@material-ui/icons/AccountCircle';
import MailIcon from '@material-ui/icons/Mail';
import NotificationsIcon from '@material-ui/icons/Notifications';
import MoreIcon from '@material-ui/icons/MoreVert';
import classNames from 'classnames';
import axios from 'axios';
import Collapse from '@material-ui/core/Collapse';
import Drawer from '@material-ui/core/Drawer';
import CssBaseline from '@material-ui/core/CssBaseline';
import List from '@material-ui/core/List';
import Divider from '@material-ui/core/Divider';
import ChevronLeftIcon from '@material-ui/icons/ChevronLeft';
import ChevronRightIcon from '@material-ui/icons/ChevronRight';
import ListItem from '@material-ui/core/ListItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemText from '@material-ui/core/ListItemText';
import BrowserIcon from '@material-ui/icons/Folder';
import SettingsIcon from '@material-ui/icons/Settings';
import ExpandLess from '@material-ui/icons/ExpandLess';
import ExpandMore from '@material-ui/icons/ExpandMore';
import SearchPage from './search/SearchPage';
import SettingsPage from './settings/SettingsPage'
import { Route, Link, withRouter, Redirect } from 'react-router-dom';
import BrowserPage from './browser/BrowserPage'
import { create } from 'jss';
import {
  createGenerateClassName,
  jssPreset,
  MuiThemeProvider,
  createMuiTheme,
} from '@material-ui/core/styles';
import blackThemeFile from './themes/black';

const jss = create({
  ...jssPreset(),
  insertionPoint: 'jss-insertion-point',
});

const generateClassName = createGenerateClassName();

const drawerWidth = 240;

const styles = theme => ({
  root: {
    width: '100%',
    display: 'flex',
  },
  grow: {
    flexGrow: 1,
  },
  appBar: {
    transition: theme.transitions.create(['margin', 'width'], {
      easing: theme.transitions.easing.sharp,
      duration: theme.transitions.duration.leavingScreen,
    }),
  },
  appBarShift: {
    width: `calc(100% - ${drawerWidth}px)`,
    marginLeft: drawerWidth,
    transition: theme.transitions.create(['margin', 'width'], {
      easing: theme.transitions.easing.easeOut,
      duration: theme.transitions.duration.enteringScreen,
    }),
  },

  menuButton: {
    marginLeft: -12,
    marginRight: 20,
  },
  title: {
    display: 'none',
    [theme.breakpoints.up('sm')]: {
      display: 'block',
    },
  },
  search: {
    position: 'relative',
    borderRadius: theme.shape.borderRadius,
    backgroundColor: fade(theme.palette.common.white, 0.15),
    '&:hover': {
      backgroundColor: fade(theme.palette.common.white, 0.25),
    },
    marginRight: theme.spacing.unit * 2,
    marginLeft: 0,
    width: '100%',
    [theme.breakpoints.up('sm')]: {
      marginLeft: theme.spacing.unit * 3,
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

  inputRoot: {
    color: 'inherit',
    width: '100%',
  },
  inputInput: {
    paddingTop: theme.spacing.unit,
    paddingRight: theme.spacing.unit * 4,
    paddingBottom: theme.spacing.unit,
    paddingLeft: theme.spacing.unit * 10,
    transition: theme.transitions.create('width'),
    width: '100%',
    [theme.breakpoints.up('md')]: {
      width: 200,
    },
  },
  sectionDesktop: {
    display: 'none',
    [theme.breakpoints.up('md')]: {
      display: 'flex',
    },
  },
  sectionMobile: {
    display: 'flex',
    [theme.breakpoints.up('md')]: {
      display: 'none',
    },
  },

  drawerHeader: {
    display: 'flex',
    alignItems: 'center',
    padding: '0 8px',
    ...theme.mixins.toolbar,
    justifyContent: 'flex-end',
  },

  hide: {
    display: 'none',
  },
  drawer: {
    width: drawerWidth,
    flexShrink: 0,
  },
  drawerPaper: {
    width: drawerWidth,
  },
  drawerHeader: {
    display: 'flex',
    alignItems: 'center',
    padding: '0px 8px',
    ...theme.mixins.toolbar,
    justifyContent: 'flex-end',
  },
  content: {
    flexGrow: 1,
    paddingLeft: theme.spacing.unit * 3,
    paddingRight: theme.spacing.unit * 3,
    paddingTop: theme.spacing.unit * 3,
    transition: theme.transitions.create('margin', {
      easing: theme.transitions.easing.sharp,
      duration: theme.transitions.duration.leavingScreen,
    }),
    marginLeft: -drawerWidth,
  },
  contentShift: {
    transition: theme.transitions.create('margin', {
      easing: theme.transitions.easing.easeOut,
      duration: theme.transitions.duration.enteringScreen,
    }),
    marginLeft: 0,
  },

  nested: {
    paddingLeft: theme.spacing.unit * 4,
    maxWidth: `${drawerWidth}px`,
    overflow: 'hidden',
    whiteSpace: 'nowrap',
    textOverflow: 'ellipsis',
  },

  sourceNameText: {
    overflow: 'hidden',
    textOverflow: 'ellipsis',
    whiteSpace: 'nowrap',
    maxWidth: `${drawerWidth - 30}px`
  }

});

class App extends React.Component {
  state = {
    anchorEl: null,
    mobileMoreAnchorEl: null,
    open: false,
    searchQuery: '',
    currentPage: 0,
    sources: [],
    browserListOpen: true,
  };

  handleDrawerOpen = () => {
    this.setState({ open: true });
  };

  handleDrawerClose = () => {
    this.setState({ open: false });
  };

  handleBrowserClick = (event) => {
    event.preventDefault();
    this.setState(state => ({ browserListOpen: !state.browserListOpen }));
  };

  componentDidMount() {
    this.updateSources()
    this.updateSourcesTimer = setInterval(()=> this.updateSources(), 1000);   
  }

  componentWillUnmount() {
    clearInterval(this.updateSourcesTimer)
  }

  updateSources = (msg, data) => {
    axios
    .get(`http://192.168.1.2:5000/sources`)
    .then(res => {
        const response = res.data;
        this.setState({ sources: response })
    });        
  }

  transition = event => {
    if (event.currentTarget.pathname )
    {
      event.preventDefault();
      // history.push({
      //   pathname: event.currentTarget.pathname,
      //   search: event.currentTarget.search,
      // });
    }
  }

  handlePartitionClick = event => {
    this.transition(event)
    if (this.props.onPartitionClick) {
      this.props.onPartitionClick(event.currentTarget.pathname)
    }
  }

  onSearchBarKeyPress = event => {
    if (event.key === 'Enter') {
      this.props.history.push({
        pathname: `/search/${event.target.value}`        
      });
    }
  };

  handleProfileMenuOpen = event => {
    this.setState({ anchorEl: event.currentTarget });
  };

  handleMenuClose = () => {
    this.setState({ anchorEl: null });
    this.handleMobileMenuClose();
  };

  handleMobileMenuOpen = event => {
    this.setState({ mobileMoreAnchorEl: event.currentTarget });
  };

  handleMobileMenuClose = () => {
    this.setState({ mobileMoreAnchorEl: null });
  };

  render() {
    const { anchorEl, mobileMoreAnchorEl, open } = this.state;
    const { classes, theme } = this.props;
    const isMenuOpen = Boolean(anchorEl);
    const isMobileMenuOpen = Boolean(mobileMoreAnchorEl);
    const blackTheme = createMuiTheme(blackThemeFile);
    const renderMenu = (
      <Menu
        anchorEl={anchorEl}
        anchorOrigin={{ vertical: 'top', horizontal: 'right' }}
        transformOrigin={{ vertical: 'top', horizontal: 'right' }}
        open={isMenuOpen}
        onClose={this.handleMenuClose}
      >
        <MenuItem onClick={this.handleMenuClose}>Profile</MenuItem>
        <MenuItem onClick={this.handleMenuClose}>My account</MenuItem>
      </Menu>
    );

    const renderMobileMenu = (
      <Menu
        anchorEl={mobileMoreAnchorEl}
        anchorOrigin={{ vertical: 'top', horizontal: 'right' }}
        transformOrigin={{ vertical: 'top', horizontal: 'right' }}
        open={isMobileMenuOpen}
        onClose={this.handleMobileMenuClose}
      >
        <MenuItem>
          <IconButton color="inherit">
            <Badge badgeContent={4} color="secondary">
              <MailIcon />
            </Badge>
          </IconButton>
          <p>Messages</p>
        </MenuItem>
        <MenuItem>
          <IconButton color="inherit">
            <Badge badgeContent={11} color="secondary">
              <NotificationsIcon />
            </Badge>
          </IconButton>
          <p>Notifications</p>
        </MenuItem>
        <MenuItem onClick={this.handleProfileMenuOpen}>
          <IconButton color="inherit">
            <AccountCircle />
          </IconButton>
          <p>Profile</p>
        </MenuItem>
      </Menu>
    );

    return (
    <MuiThemeProvider theme={blackTheme}>
      <div className={classes.root}>
        <CssBaseline />
        <AppBar
          position="fixed"
          className={classNames(classes.appBar, {
            [classes.appBarShift]: open,
          })}
        >
          <Toolbar>
            <IconButton
              className={classes.menuButton}
              color="inherit"
              aria-label="Open drawer"
              onClick={this.handleDrawerOpen}
            >
              <MenuIcon />
            </IconButton>
            <Typography
              className={classes.title}
              variant="h6"
              color="inherit"
              noWrap
            >
              HurraCloud
            </Typography>
            <div className={classes.search}>
              <div className={classes.searchIcon}>
                <SearchIcon />
              </div>
              <InputBase
                placeholder="Search your files"
                onKeyPress={this.onSearchBarKeyPress}
                classes={{
                  root: classes.inputRoot,
                  input: classes.inputInput,
                }}
              />
            </div>
            <div className={classes.grow} />
            <div className={classes.sectionDesktop}>
              <IconButton color="inherit">
                <Badge badgeContent={4} color="secondary">
                  <MailIcon />
                </Badge>
              </IconButton>
              <IconButton color="inherit">
                <Badge badgeContent={17} color="secondary">
                  <NotificationsIcon />
                </Badge>
              </IconButton>
              <IconButton
                aria-owns={isMenuOpen ? 'material-appbar' : undefined}
                aria-haspopup="true"
                onClick={this.handleProfileMenuOpen}
                color="inherit"
              >
                <AccountCircle />
              </IconButton>
            </div>
            <div className={classes.sectionMobile}>
              <IconButton
                aria-haspopup="true"
                onClick={this.handleMobileMenuOpen}
                color="inherit"
              >
                <MoreIcon />
              </IconButton>
            </div>
          </Toolbar>
        </AppBar>
        {renderMenu}
        {renderMobileMenu}
        <Drawer
          className={classes.drawer}
          variant="persistent"
          anchor="left"
          open={open}
          classes={{
            paper: classes.drawerPaper,
          }}
        >
          <div className={classes.drawerHeader}>
            <IconButton onClick={this.handleDrawerClose}>
              {theme.direction === 'ltr' ? (
                <ChevronLeftIcon />
              ) : (
                <ChevronRightIcon />
              )}
            </IconButton>
          </div>
          <Divider />
          <List>
            <Link to={`/search/`} style={{ textDecoration: 'none' }}>
                <ListItem button key="Search" selected={this.props.history.location.pathname.startsWith(`/search/`)}>
                  <ListItemIcon><SearchIcon /></ListItemIcon>
                  <ListItemText primary="Search" style={{color:'black'}} />
                </ListItem>
            </Link>        
                              
            <ListItem button key="Browse" selected={this.props.history.location.pathname.startsWith(`/browse/`)} onClick={this.handleBrowserClick}>
                <ListItemIcon><BrowserIcon /></ListItemIcon>
                <ListItemText primary="Browse" style={{color:'black'}} />
                {this.state.browserListOpen ? <ExpandLess /> : <ExpandMore />}
              </ListItem>
              <Collapse in={this.state.browserListOpen} timeout="auto" unmountOnExit>
              <List component="div" disablePadding>                    
                  {this.state.sources.map(source => {
                    let icon_class = "fab fa-usb"
                    if (source.source_type == "system")
                      icon_class = "fas fa-database"
                    else if (source.source_type == "internal")
                      icon_class = "fab fa-hdd"
                    return source.device_partitions.filter(p => p.status == "mounted").map(partition => {
                        return <Link
                        to={`/browse/${source.id}/${partition.label}`}
                        style={{ textDecoration: 'none', color:'black' }}
                        >       
                            <ListItem button className={classes.nested}>
                                <div style={{float:'left'}}><span
                                      className={`${icon_class}`}
                                      style={{ marginRight: '0.5em', width:'10px', }}
                                      />
                                      </div> 
                            <ListItemText inset primary={partition.label} className={classes.sourceNameText} />
                          </ListItem>
                          </Link>
                    })
                  })}
                </List>
              </Collapse>
              <Divider />
              <Link to={`/manage/`} style={{ textDecoration: 'none' }}>
                <ListItem button key="Manage" selected={this.props.history.location.pathname.startsWith(`/manage/`)}>
                  <ListItemIcon><SettingsIcon /></ListItemIcon>
                  <ListItemText primary="Manage" style={{color:'black'}} />
                </ListItem>
              </Link>

          </List>
        </Drawer>
        <main
          className={classNames(classes.content, {
            [classes.contentShift]: open,
          })}
        >
          <div className={classes.drawerHeader} />
          <Route exact={true} path="/" render={() => (<Redirect from="/" to="/search/" />)} />          
          <Route path="/browse/:path+" render={({match}) => (<BrowserPage path={match.params.path || ""} />)}/>
          <Route path="/search/:terms?" render={({match}) => (<SearchPage searchTerms={match.params.terms || ""} />)}/>
          <Route path="/manage" render={() => (<SettingsPage sources={this.state.sources} />)}/>
        </main>
      </div>
  </MuiThemeProvider>
    );
  }
}

App.propTypes = {
  classes: PropTypes.object.isRequired,
  theme: PropTypes.object.isRequired,
  onNewSearch: PropTypes.func,
  onPartitionClick: PropTypes.func
};

export default withRouter(withStyles(styles, { withTheme: true })(App));
