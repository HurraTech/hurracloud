import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import Button from '@material-ui/core/Button';
import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogTitle from '@material-ui/core/DialogTitle';
import Slide from '@material-ui/core/Slide';
import TextField from '@material-ui/core/TextField';

const styles = {
  appBar: {
    position: 'relative',
  },
  appBarBottom: {
      top:'auto',
      bottom: 0
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
    ""
]

class RevokeUserDialog extends React.Component {

  state = {
    open: false,
    adminPassword: "",
  };

  componentDidUpdate(prevProps) {
    if (prevProps.open != this.props.open) {
      this.setState({open: this.props.open})
    }
  }


  handleSave = () => {
    this.props.onSave(this.state.adminPassword)
  }

  handleFieldChange = fieldName => event => {
    this.setState({[fieldName]: event.target.value})
  }

  render() {
    const { onClose } = this.props;

    return (
      <div>
        <Dialog
          open={this.state.open}
          onClose={onClose}
          TransitionComponent={Transition}
        >
          <DialogTitle id="form-dialog-title">Are you sure?</DialogTitle>
          <DialogContent>
            <DialogContentText>
              Please enter your Master Password proceed. Note that this is cannot be undone, you will have to create a new user and new credentials as you cannot reinstate revoked credentials.
            </DialogContentText>
            <TextField
              margin="normal"
              id="password"
              label="Master Password"
              type="password"
              value={this.state.adminPassword}
              onChange={this.handleFieldChange("adminPassword")}
              fullWidth
            />                        
          </DialogContent>
          <DialogActions>
            <Button onClick={onClose} color="primary">
              Cancel
            </Button>
            <Button onClick={this.handleSave} color="primary">
              Revoke User's Access
            </Button>
          </DialogActions>

        </Dialog>
      </div>
    );
  }
}

RevokeUserDialog.propTypes = {
  classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(RevokeUserDialog);
