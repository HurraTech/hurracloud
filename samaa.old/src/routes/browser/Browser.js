import React from 'react';
import PropTypes from 'prop-types';
import Paper from '@material-ui/core/Paper';
import { withStyles } from '@material-ui/core/styles';
import axios from 'axios';
import FilePreview from '../../components/FilePreview';
import { throttle, debounce } from 'throttle-debounce';
import BrowserTable from './BroswerTable';
import ProgressIndicator from '../../components/ProgressIndicator';
import history from '../../history';

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

class Content extends React.Component {
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
    this.searchDebounced = debounce(500, this.search);
    this.searchThrottled = throttle(500, this.search);
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
    history.goBack()

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
    history.push({ pathname: `/browse/${requestedPath}`});  
    this.setState({path: requestedPath}, () => { this.browse() } )

    // this.setState(
    //   {
    //     isAjaxInProgress: true,
    //     isInlineViewerOpen: false,
    //     isPreviewOpen: false,
    //     openedFile: '',
    //     path: requestedPath
    //   },
    //   () => {
    //     if (type == 'folder' || type.indexOf('source_') == 0) {
    //       console.log("Requesed path", requestedPath)          
    //       this.browse().then(() => {
    //         this.setState({
    //           isAjaxInProgress: false,
    //           isInlineViewerOpen: false,
    //           isPreviewOpen: false,
    //           openedFile: '',
    //         });
    //       });
    //     } else {
    //       this.openFile()
    //     }
    //   },
    // );
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

    window.onpopstate = ()=> {
      console.log(location)
      this.setState({
        path: location.pathname.replace("/browse/", ""),
      }, () => {        
        this.browse()
      })
    }

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

Content.propTypes = {
  classes: PropTypes.object.isRequired,
};

const deepDiffMapper = (function() {
  return {
    VALUE_CREATED: 'created',
    VALUE_UPDATED: 'updated',
    VALUE_DELETED: 'deleted',
    VALUE_UNCHANGED: 'unchanged',
    map(obj1, obj2) {
      if (this.isFunction(obj1) || this.isFunction(obj2)) {
        throw 'Invalid argument. Function given, object expected.';
      }
      if (this.isValue(obj1) || this.isValue(obj2)) {
        return {
          type: this.compareValues(obj1, obj2),
          data: obj1 === undefined ? obj2 : obj1,
        };
      }

      const diff = {};
      for (var key in obj1) {
        if (this.isFunction(obj1[key])) {
          continue;
        }

        let value2;
        if (typeof obj2[key] !== 'undefined') {
          value2 = obj2[key];
        }

        diff[key] = this.map(obj1[key], value2);
      }
      for (var key in obj2) {
        if (this.isFunction(obj2[key]) || typeof diff[key] !== 'undefined') {
          continue;
        }

        diff[key] = this.map(undefined, obj2[key]);
      }

      return diff;
    },
    compareValues(value1, value2) {
      if (value1 === value2) {
        return this.VALUE_UNCHANGED;
      }
      if (
        this.isDate(value1) &&
        this.isDate(value2) &&
        value1.getTime() === value2.getTime()
      ) {
        return this.VALUE_UNCHANGED;
      }
      if (typeof value1 === 'undefined') {
        return this.VALUE_CREATED;
      }
      if (typeof value2 === 'undefined') {
        return this.VALUE_DELETED;
      }

      return this.VALUE_UPDATED;
    },
    isFunction(obj) {
      return {}.toString.apply(obj) === '[object Function]';
    },
    isArray(obj) {
      return {}.toString.apply(obj) === '[object Array]';
    },
    isDate(obj) {
      return {}.toString.apply(obj) === '[object Date]';
    },
    isObject(obj) {
      return {}.toString.apply(obj) === '[object Object]';
    },
    isValue(obj) {
      return !this.isObject(obj) && !this.isArray(obj);
    },
  };
})();

export default withStyles(styles)(Content);
