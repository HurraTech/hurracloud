import React from 'react';
import Button from '@material-ui/core/Button';
import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogTitle from '@material-ui/core/DialogTitle';

class AlertDialog extends React.Component {
  state = {
    open: this.props.open || false,
    message: this.props.message || "",
    cancelButton: this.props.cancelButton || "Cancel",
    okButton: this.props.okButton || "OK",
    title: this.props.title || ""
  };

  handleCancel = () => {
    if (this.props.onCancel)
        this.props.onCancel()
        
  };

  handleOk = () => {
    if (this.props.onOk)
        this.props.onOk()

  };

  componentDidUpdate = (prevProps) => {
    if (this.props.open != prevProps.open) {
        this.setState({
            open: this.props.open            
        })
    }
  }

  render() {
    return (
      <div>
        <Dialog
          open={this.state.open}
          onClose={this.handleCancel}
          aria-labelledby="alert-dialog-title"
          aria-describedby="alert-dialog-description"
        >
          <DialogTitle id="alert-dialog-title">{this.state.title}</DialogTitle>
          <DialogContent>
            <DialogContentText id="alert-dialog-description">
              {this.state.message}
            </DialogContentText>
          </DialogContent>
          <DialogActions>
            <Button onClick={this.handleCancel} color="primary">
              {this.state.cancelButton}
            </Button>
            <Button onClick={this.handleOk} color="primary" autoFocus>
            {this.state.okButton}
            </Button>
          </DialogActions>
        </Dialog>
      </div>
    );
  }
}

export default AlertDialog;
