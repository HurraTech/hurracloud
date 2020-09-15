import React from 'react';
import PropTypes from 'prop-types';
import Paper from '@material-ui/core/Paper';
import { withStyles } from '@material-ui/core/styles';
import axios from 'axios';
import FilePreview from '../components/FilePreview';
import BrowserTable from './BroswerTable';
import ProgressIndicator from '../components/ProgressIndicator';
import { withRouter } from 'react-router-dom'
import { JAWHAR_API, JAWHAR_NEW_API  } from '../constants';

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
    height: "100%",
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
    const is_dir = this.state.items[index].IsDir;
    const path = is_dir ? "/browse" + this.state.items[index].Path : "/browse/preview" + this.state.items[index].Path
    if (path == "..")
    {
      // Going one level up
      console.log("Going level up from ", this.state.path)
      path = this.state.path.substring(0, this.state.path.lastIndexOf("/"))
    }
    console.log(`Clicked on ${path}`)

    this.props.history.push({ pathname: path});
  };


  componentDidMount() {
    this.browse();
  }

  browse() {
    return new Promise((resolve, reject) => {
      this.setState({isAjaxInProgress: true}, () => {
        console.log("Making request to ", JAWHAR_NEW_API, this.state.path)
        axios.get(`${JAWHAR_NEW_API}/${this.state.path}`).then(res => {
          const response = res.data;
          console.log("Response", response)
          this.setState(
            {
              items: response.content,
              isInlineViewerOpen: false,
              isPreviewOpen: false,
              isAjaxInProgress: false
            },
            () => {
              resolve(response.content);
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
