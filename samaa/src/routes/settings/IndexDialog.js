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

const styles = {
  appBar: {
    position: 'relative',
  },
  flex: {
    flex: 1,
  },
};

function Transition(props) {
  return <Slide direction="up" {...props} />;
}

class IndexDialog extends React.Component {
  state = {
    open: false,
    editIndexId: 0,
    partitionObject: {}
  };

  handleClickOpen = () => {
    this.setState({ open: true });
  };

  handleClose = () => {
    this.setState({ open: false });
  };

  componentDidUpdate(prevProps) {
    if (prevProps.open != this.props.open) {
        this.setState({open: this.props.open, partitionObject: this.props.partitionObject})
    }
  }

  render() {
    const { classes, onClose, onSave } = this.props;
    const { editIndexId, partitionObject } = this.state;
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
              <Button color="inherit" onClick={onSave}>
                save
              </Button>
            </Toolbar>
          </AppBar>
          <List>
            <ListItem button>
              <ListItemText primary="Excluded Files" secondary="What files to exclude from indexing" />
              <TextField
                id="standard-name"
                label="Name"
                margin="normal"
                />

            </ListItem>
            <Divider />
            <ListItem button>
              <ListItemText primary="Default notification ringtone" secondary="Tethys" />
            </ListItem>
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
