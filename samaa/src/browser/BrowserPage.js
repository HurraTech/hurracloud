import React from 'react';
import PropTypes from 'prop-types';
import Paper from '@material-ui/core/Paper';
import { withStyles } from '@material-ui/core/styles';
import axios from 'axios';
import FilePreview from '../components/FilePreview';
import BrowserTable from './BroswerTable';
import ProgressIndicator from '../components/ProgressIndicator';
import { withRouter } from 'react-router-dom'
import { JAWHAR_API  } from '../constants';

const styles = theme => ({
  paper: {
    maxWidth: '100%',
    margin: 'auto',
    overflow: 'hidden',
    height: "85vh",
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
  progressWrapper: {
    bottom: 0,
  }
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
      requestedItem: null,
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
    const path = this.state.items[index].internal_name;
    const type = this.state.items[index].type;
    let requestedPath = `${type != 'folder' ? '_open_/' :''}${this.state.path}/${path}`;
    if (path == "..")
    {
      // Going one level up
      requestedPath = this.state.path.substring(0, this.state.path.lastIndexOf("/"))
    }
    console.log(`Clicked on ${path} of type ${type}`)
    this.props.history.push({ pathname: `/browse/${requestedPath}`});
  };

  openFile() {
    return new Promise((resolve, reject) => {
      // if (this.state.requestedItem.openLink != null)
      // {
      //     window.open(this.state.requestedItem.openLink, "_blank")
      //     return;
      // }

      this.setState({isAjaxInProgress: true}, () => {
        axios
        .get(`${JAWHAR_API}/files/is_viewable/${this.state.path.replace('_open_/', '')}`)
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
              window.location = `${JAWHAR_API}/files/download/${this.state.path.replace('_open_/', '')}`;
              let path = `/browse/${this.state.path.substring(0, this.state.path.lastIndexOf("/")).replace("_open_/", "")}`
              this.props.history.push({ pathname: path});
            }
          });
        });
      })
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
      this.setState({isAjaxInProgress: true}, () => {
        axios.get(`${JAWHAR_API}/files/browse/${this.state.path}`).then(res => {
          const response = res.data;
          console.log("Response", response)
          this.setState(
            {
              items: response.contents,
              isInlineViewerOpen: false,
              isPreviewOpen: false,
              isAjaxInProgress: false
            },
            () => {
              resolve(response.contents);
            },
          );
        });
      })
    });
  }

  render() {
    const { classes } = this.props;
    const { items } = this.state;
    return (<span>
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
      </Paper>
      <div class={classes.progressWrapper}>{this.state.isAjaxInProgress && <ProgressIndicator />}</div></span>
    );
  }
}

BrowserPage.propTypes = {
  classes: PropTypes.object.isRequired,
};


export default withRouter(withStyles(styles)(BrowserPage));
