import React from 'react';
import PropTypes from 'prop-types';
import Paper from '@material-ui/core/Paper';
import { withStyles } from '@material-ui/core/styles';
import axios from 'axios';
import FilePreview from '../components/FilePreview';
import BrowserTable from './BroswerTable';
import ProgressIndicator from '../components/ProgressIndicator';
import { withRouter } from 'react-router-dom'

const styles = theme => ({
  paper: {
    maxWidth: '100%',
    margin: 'auto',
    overflow: 'hidden',
  },
  searchBar: {
    borderBottom: '1px solid rgba(0, 0, 0, 0.12)',
  },
  searchInput: {
    fontSize: theme.typography.fontSize,
  },
  block: {
    display: 'block',
  },
  addUser: {
    marginRight: theme.spacing.unit,
  },
  contentWrapper: {
    margin: '0px 0px',
  },
});

class BrowserPage extends React.Component {
  constructor(props) {
    super(props);
    console.log("Initial path is ", props.path)
    this.state = {
      error: null,
      isInstantSearchEnabled: false,
      isPreviewOpen: false,
      isLoaded: false,
      previewedContent: [],
      openedFile: '',
      isInlineViewerOpen: false,
      previewedTitle: '',
      isAjaxInProgress: false,
      path: props.path,
      items: [],

      searchTerms: [],
    };
  }

  handlePreviewCloseClick() {    
    let backPath = this.state.path.substring(0, this.state.path.lastIndexOf("/"))
    console.log("Closing preview, going to this path", backPath)
    this.setState({
      isPreviewOpen: false,
      isInlineViewerOpen: false,
      openedFile: '',
      path: backPath
    });
    this.props.history.goBack()

  }

  componentDidUpdate(prevProps) {
    if (this.props.path !== prevProps.path) {
      this.setState({
        path: this.props.path
      }, () => {
        console.log("Going to ", this.state.path)
        this.browse()
      })
    }
  }

  handlePreviewClick = index => {
    const highlighted_content =
      this.state.items[index].highlight &&
      this.state.items[index].highlight.content
        ? this.state.items[index].highlight.content
        : null;

    const full_content =
      this.state.items[index]._source.content &&
      this.state.items[index]._source.content.trim() != ''
        ? [this.state.items[index]._source.content.trim()]
        : null;
    const preview_content = highlighted_content || full_content;

    if (preview_content) {
      this.setState({
        isPreviewOpen: true,
        isInlineViewerOpen: false,
        openedFile: `${this.state.path}/${this.state.items[index].name}`,
        previewedContent: preview_content,
        previewedTitle: this.state.items[index]._source.file.filename,
      });
    }
  };

  handleFilenameClick = index => {
    const path = this.state.items[index].name;
    const type = this.state.items[index].type;
    console.log(`Clicked on ${path} of type ${type}`)
    let requestedPath = `${type != 'folder' ? '_open_/' :''}${this.state.path}/${path}`;
    this.props.history.push({ pathname: `/browse/${requestedPath}`});  
    this.setState({path: requestedPath}, () => { this.browse() } )
  };

  openFile() {
    return new Promise((resolve, reject) => {
      axios
      .get(`http://192.168.1.2:5000/files/is_viewable/${this.state.path.replace('_open_/', '')}`)
      .then(res => {
        this.setState({ isAjaxInProgress: false }, () => {
          const isViewable = res.data.is_viewable;
          if (isViewable) {
            this.setState({
              openedFile: this.state.path.replace('_open_/', ''),
              isInlineViewerOpen: true,
              isPreviewOpen: false,
            });
          } else {
            window.location = `http://192.168.1.2:5000/files/download/${this.state.path.replace('_open_/', '')}`;
          }
        });
      });    
    })
  }

  componentDidMount() {
    this.browse();
  }

  browse() {
    console.log("Making request to ", this.state.path)
    if (this.state.path.startsWith("_open_/")) {
      return this.openFile()
    }
    return new Promise((resolve, reject) => {
      axios.get(`http://192.168.1.2:5000/files/browse/${this.state.path}`).then(res => {
        const response = res.data;
        console.log("Response", response)
        this.setState(
          {
            items: response.contents,
            isInlineViewerOpen: false,
            isPreviewOpen: false,
          },
          () => {
            resolve(response.contents);
          },
        );
      });
    });
  }

  render() {
    const { classes } = this.props;
    const { items } = this.state;
    return (
      <Paper className={classes.paper}>
        <FilePreview
          open={this.state.isInlineViewerOpen}
          onCloseClick={this.handlePreviewCloseClick.bind(this)}
          file={this.state.openedFile}
        />
        <div className={classes.contentWrapper}>
          <BrowserTable
            rowCount={this.state.items.length}
            rowGetter={({ index }) => ({ file: items[index] })}
            onPreviewClick={this.handlePreviewClick}
            onFilenameClick={this.handleFilenameClick}
            classes={classes.table}
            searchTerms={this.state.searchTerms}
            columns={[
              {
                width: 200,
                flexGrow: 1.0,
                label: 'File',
                dataKey: 'file',
                content: 'filename',
              },
              {
                width: 100,
                label: 'Size',
                dataKey: 'file',
                content: 'size',
                numeric: true,
              },
              {
                width: 150,
                label: 'Created',
                dataKey: 'file',
                content: 'created',
                numeric: true,
              },
              {
                width: 40,
                label: '',
                dataKey: 'file',
                content: 'downloadButton',
              },
            ]}
          />
        </div>
        {this.state.isAjaxInProgress && <ProgressIndicator />}
      </Paper>
    );
  }
}

BrowserPage.propTypes = {
  classes: PropTypes.object.isRequired,
};


export default withRouter(withStyles(styles)(BrowserPage));
