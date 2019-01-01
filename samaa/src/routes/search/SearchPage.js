import React from 'react';
import PropTypes from 'prop-types';
import Paper from '@material-ui/core/Paper';
import { withStyles } from '@material-ui/core/styles';
import InstantSearchIcon from '@material-ui/icons/Sync';
import InstantSearchIconDisabled from '@material-ui/icons/SyncDisabled';
import axios from 'axios';
import QuickPreview from './QuickPreview';
import FilePreview from './FilePreview';
import { throttle, debounce } from 'throttle-debounce';
import SearchResultsTable from './SearchResultsTable';
import ProgressIndicator from '../../components/ProgressIndicator';
import history from '../../history'
import QueryString from 'query-string'
const SIZE = 30;

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
      items: [],
      query: this.props.searchTerms,
      totalResults: 0,
    };
    this.searchDebounced = debounce(500, this.search);
    this.searchThrottled = throttle(500, this.search);
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
        openedFile: this.state.items[index]._source.path,
        previewedContent: preview_content,
        previewedTitle: this.state.items[index]._source.file.filename,
      });
    }
  };

  handleFilenameClick = index => {
    const path = this.state.items[index]._source.path;
    this.setState(
      {
        isAjaxInProgress: true,
        isInlineViewerOpen: false,
        isPreviewOpen: false,
        openedFile: '',
      },
      () => {
        axios
          .get(`http://192.168.1.2:5000/files/is_viewable/${path}`)
          .then(res => {
            this.setState({ isAjaxInProgress: false }, () => {
              const isViewable = res.data.is_viewable;
              if (isViewable) {
                this.setState({
                  openedFile: path,
                  isInlineViewerOpen: true,
                  isPreviewOpen: false,
                });
              } else {
                window.location = `http://192.168.1.2:5000/files/download/${path}`;
              }
            });
          });
      },
    );
  };

  componentWillReceiveProps(nextProps) {
    this.searchWrapper(nextProps.searchTerms, this.search);
  }

  componentDidMount() {
    this.search()
  }

  // componentShouldUpdate(props, nextProps) {
  //   console.log("Should I ")
  //   if (props.searchTerms == nextProps.searchTerms)
  //     return false
  //   return true
  // }

  handlePreviewCloseClick() {
    this.setState({
      isPreviewOpen: false,
      isInlineViewerOpen: false,
      openedFile: '',
    });
  }

  searchWrapper = (query, searchFunction) => {
    
    this.setState(
      {
        q: query,
        isPreviewOpen: false,
        isAjaxInProgress: true,
        isInlineViewerOpen: false,
        items: [],
        totalResults: 0,
        openedFile: '',
      },
      searchFunction,
    );
  };

  onLoadMore(from, to) {
    return new Promise((resolve, reject) => {
      this.setState(
        {
          isPreviewOpen: false,
          isInlineViewerOpen: false,
          openedFile: '',
        },
        () => {
          resolve(this.search(from, to));
        },
      );
    });
  }

  search(from = 0, to = SIZE) {
    const query = this.state.q || '';
    return new Promise((resolve, reject) => {
      axios
        .get(`http://192.168.1.2:5000/search?q=${query}&from=${from}&to=${to}`)
        .then(res => {
          const response = res.data;
          this.setState(
            {
              totalResults: Math.min(1000, response.total),
              items: this.state.items.concat(response.hits),
              isAjaxInProgress: false
            },
            () => {
              resolve(response.hits);
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
        <QuickPreview
          open={this.state.isPreviewOpen}
          onCloseClick={this.handlePreviewCloseClick.bind(this)}
          content={this.state.previewedContent}
          title={`Preview (${this.state.previewedTitle})`}
        />
        <FilePreview
          open={this.state.isInlineViewerOpen}
          onCloseClick={this.handlePreviewCloseClick.bind(this)}
          file={this.state.openedFile}
        />
        <div className={classes.contentWrapper}>
          <SearchResultsTable
            rowCount={this.state.totalResults}
            rowGetter={({ index }) => ({ file: items[index] })}
            onPreviewClick={this.handlePreviewClick}
            onFilenameClick={this.handleFilenameClick}
            classes={classes.table}
            onLoadMore={this.onLoadMore.bind(this)}
            query={this.state.q}
            columns={[
              {
                width: 40,
                label: '',
                dataKey: 'file',
                content: 'downloadButton',
              },
              {
                width: 40,
                label: '',
                dataKey: 'file',
                content: 'openButton',
              },
              {
                width: 40,
                label: '',
                dataKey: 'file',
                content: 'previewButton',
              },
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
