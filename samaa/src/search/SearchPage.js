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
import {FormControl, InputLabel, Input, FormHelperText} from '@material-ui/core';
import { Typography, Select, MenuItem, List, ListItem } from '@material-ui/core'

const SIZE = 30;

const styles = theme => ({
  filterPaper: {
    padding: "10px"
  },

  heading: {
    fontSize: theme.typography.pxToRem(18),
    color: theme.palette.text.secondary,
    width: "80px"
  },

  paper: {
    maxWidth: '100%',
    margin: 'auto',
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
    height: "80vh",
    flex: 1,
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
    this.props.history.push({ pathname: `/search/${this.props.selectSourceType}/${this.props.selectSourceID}/preview${path}`, search: this.props.location.search});
  };


  componentDidUpdate(prevProps) {
    const prevQuery = this.query(prevProps);
    const newQuery = this.query()

    if (prevQuery  !== newQuery || this.props.selectSourceType !== prevProps.selectSourceType || this.props.selectSourceID !== prevProps.selectSourceID ) {
      this.searchWrapper(newQuery, this.search);
    }
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
    const query = this.query();
    if (query) {
      return new Promise((resolve, reject) => {
        axios
          .post(`${JAWHAR_NEW_API}/sources/${this.props.selectSourceType}/${this.props.selectSourceID}/search?q=${query}&from=${from}&to=${to}`)
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
    } else {
      return new Promise((resolve, reject) => {
        console.log("Empty Query")
        this.setState(
          {
            totalResults: 0,
            items: [],
            emptyQuery: true,
            isAjaxInProgress: false,
          },
          () => {
            resolve([]);
          },
        );
      })
    }
  }

  query(fromProps) {
    const props = fromProps || this.props
    const parsedQuery = QueryString.parse(props.location.search)
    return parsedQuery.q
  }

  source(fromProps) {
    const props = fromProps || this.props
    return `${this.props.selectSourceType}-${this.props.selectSourceID}`
  }

  render() {
    const { classes } = this.props;

    const { items } = this.state;
    return (
      <span>
        <Paper className={classes.filterPaper}>
          <ListItem>
              <Typography className={classes.heading}> Index</Typography>
              <Select value={this.source()} onChange={(event) => {
                    console.log("Changed source", event.target.value)
                    let c = event.target.value.split("-")
                    let sourceType = c[0]
                    let sourceID = c[1]
                    this.props.history.push({ pathname: `/search/${sourceType}/${sourceID}`, search: this.props.location.search});
              }}>
                {this.props.sources.filter(s => s.Status == "mounted" && s.IndexStatus != "").map((source, index) => {
                  return (
                    <MenuItem value={`${source.Type}-${source.ID}`} >{source.Caption}</MenuItem>)
                  })}
              </Select>
          </ListItem>
        </Paper>
        <br/>
        <Paper className={classes.paper}>
        <div className={classes.contentWrapper} >
          <SearchResultsTable
            rowCount={this.state.totalResults}
            rowGetter={({ index }) => ({ file: items[index] })}
            onPreviewClick={this.handlePreviewClick}
            onFilenameClick={this.handleFilenameClick}
            classes={classes.table}
            onLoadMore={this.onLoadMore.bind(this)}
            query={this.query()}
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
