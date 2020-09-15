import React from 'react';
import PropTypes from 'prop-types';
import Paper from '@material-ui/core/Paper';
import { withStyles } from '@material-ui/core/styles';
import { withRouter } from 'react-router-dom'
import axios from 'axios';
import QuickPreview from '../components/QuickPreview';
import FilePreview from '../components/FilePreview';
import SearchResultsTable from './SearchResultsTable';
import ProgressIndicator from '../components/ProgressIndicator';
import QueryString from 'query-string';
import { JAWHAR_API, JAWHAR_NEW_API  } from '../constants';

const SIZE = 30;

const styles = theme => ({
  paper: {
    maxWidth: '100%',
    margin: 'auto',
    overflow: 'hidden',
    height: "85vh"
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
    height: "100vh",
    flex: 1,
  },
});

class Content extends React.Component {
  constructor(props) {
    super(props);
    const query = QueryString.parse(this.props.location.search)

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
      q: query.q,
      totalResults: 1000,
    };
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
    const path = this.state.items[index].Path;
    this.props.history.push({ pathname: `/preview${path}`});
    // this.setState(
    //   {
    //     isAjaxInProgress: true,
    //     isInlineViewerOpen: false,
    //     isPreviewOpen: false,
    //     openedFile: '',
    //   },
    //   () => {
    //     axios
    //       .get(`${JAWHAR_NEW_API}/${path}`)
    //       .then(res => {
    //         this.setState({ isAjaxInProgress: false }, () => {
    //           const isViewable = res.data.is_viewable;
    //           if (isViewable) {
    //             this.setState({
    //               openedFile: path,
    //               isInlineViewerOpen: true,
    //               isPreviewOpen: false,
    //             });
    //           } else {
    //             window.location = `${JAWHAR_API}/files/download/${path}`;
    //           }
    //         });
    //       });
    //   },
    // );
  };

  componentDidMount() {
    console.log("Component update")
    const query = QueryString.parse(this.props.location.search)
    this.searchWrapper(query.q, this.search);
  }

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
    const query = this.state.q || '*';
    return new Promise((resolve, reject) => {
      axios
        .post(`${JAWHAR_NEW_API}/sources/partition/5/search?q=${query}&from=${from}&to=${to}`)
        .then(res => {
          const response = res.data;
          this.setState(
            {
              totalResults: Math.min(1000, response.length),
              items: this.state.items.concat(response),
              isAjaxInProgress: false,
            },
            () => {
              resolve(response);
            },
          );
        });
    });
  }

  render() {
    const { classes } = this.props;

    const { items } = this.state;
    return (
      <span><Paper className={classes.paper}>
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
        <div className={classes.contentWrapper} >
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
      </Paper>
      <div>{this.state.isAjaxInProgress && <ProgressIndicator />}</div></span>
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

export default withRouter(withStyles(styles)(Content));
