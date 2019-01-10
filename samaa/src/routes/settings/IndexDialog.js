import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import Button from '@material-ui/core/Button';
import Dialog from '@material-ui/core/Dialog';
import ListItemText from '@material-ui/core/ListItemText';
import ListItem from '@material-ui/core/ListItem';
import List from '@material-ui/core/List';
import Divider from '@material-ui/core/Divider';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import IconButton from '@material-ui/core/IconButton';
import Typography from '@material-ui/core/Typography';
import CloseIcon from '@material-ui/icons/Close';
import Slide from '@material-ui/core/Slide';
import TextField from '@material-ui/core/TextField';
import Grid from '@material-ui/core/Grid';

const styles = {
  appBar: {
    position: 'relative',
  },
  appBarBottom: {
      top:'auto',
      bottom: 0
  },

  flex: {
    flex: 1,
  },

  patternsGrid: {
    height: "500px",
    padding: "20px",
    width: 'auto',
    paddingBottom: 0,
    paddingTop: 0,
    margin: 0
  },

  patternsGridItem: {
    padding: 0
  },

  formListItem: {
      paddingTop:0 ,
      paddingBottom:0 ,
  }
};

function Transition(props) {
  return <Slide direction="up" {...props} />;
}

const DEFAULT_EXCLUDES_LIST = [
    "*/~*",
    "*.yfull",
    "*.kdbx",
    "*/.DS_Store",
    "*/.*",
    ""
]

class IndexDialog extends React.Component {

  state = {
    open: false,
    editIndexId: 0,
    partitionObject: {},
    excludeList: []
  };

  handleClickOpen = () => {
    this.setState({ open: true });
  };

  handleClose = () => {
    this.setState({ open: false });
  };

  componentDidUpdate(prevProps) {
    if (prevProps.open != this.props.open) {
        let excludes = DEFAULT_EXCLUDES_LIST.slice()
        if (this.props.partitionObject.index)
        {
            console.log(" I am here?")
            excludes = this.props.partitionObject.index.settings &&  
                          this.props.partitionObject.index.settings.excludes ?
                            this.props.partitionObject.index.settings.excludes : [""]
        }
        console.log("Updating excludeList to", excludes)
        this.setState({open: this.props.open,
            partitionObject: this.props.partitionObject,
            excludeList: excludes
        })
    }
  }

  addPatternChange = (i) => (e) => {
        this.state.excludeList[i] = e.target.value
        if (e.target.value.length >= 1 && i == this.state.excludeList.length - 1)
            this.state.excludeList.push("")
        this.forceUpdate()
  }

  onPatternBlur = (i) => (e) => {
        if (e.target.value.length == 0 && i < this.state.excludeList.length-1) {
            this.state.excludeList.splice(i, 1)
            this.forceUpdate()
        }

  }

  handleSave = () => {
      if (this.props.onSave)
        this.props.onSave({
            excludes: this.state.excludeList
        })
  }
  

  render() {
    const { classes, onClose, onSave } = this.props;
    const { editIndexId, partitionObject, excludeList } = this.state;
    const patternFields = [];
    let j =0;
    for (; j < excludeList.length; j++) {
        patternFields.push(<Grid item lg={3} className={classes.patternsGridItem}>
                <TextField
                value={excludeList[j]}
                label="Exclude Pattern"
                margin="normal"
                onChange={this.addPatternChange(j)}
                onBlur={this.onPatternBlur(j)} />
                </Grid>)

    }
    return (
      <div>
        <Dialog
          fullScreen
          open={this.state.open}
          onClose={onClose}
          TransitionComponent={Transition}
        >
          <AppBar className={classes.appBar}>
            <Toolbar>
              <IconButton color="inherit" onClick={onClose} aria-label="Close">
                <CloseIcon />
              </IconButton>
              <Typography variant="h6" color="inherit" className={classes.flex}>
                {editIndexId > 0 ? "Edit Index" : `Create New Index for ${partitionObject.label}`}
              </Typography>
            </Toolbar>
          </AppBar>
          <List>
            <ListItem button>
                    <ListItemText primary="Excluded Files" secondary="What files to exclude from indexing" />
            </ListItem>
            <Grid container spacing={0}>
                <Grid item container xs="5"
                    spacing={0}
                    direction="column"
                    alignContent="flext-start"
                    className={classes.patternsGrid}
                    alignItems="flext-start"
                    justify="flext-start"
                    >
                {patternFields}
                </Grid>
                <Grid item xs="auto"></Grid>
            </Grid>
            <AppBar className={classes.appBarBottom}>
            <Toolbar>
                <Button onClick={this.handleSave} color="secondary">
                    {editIndexId > 0 ? "Save" : "Create Index" }
                </Button>
            </Toolbar>
          </AppBar>
          </List>
        </Dialog>
      </div>
    );
  }
}

IndexDialog.propTypes = {
  classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(IndexDialog);
