import React from 'react';
import PropTypes from 'prop-types';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Paper from '@material-ui/core/Paper';
import Grid from '@material-ui/core/Grid';
import TextField from '@material-ui/core/TextField';
import Tooltip from '@material-ui/core/Tooltip';
import IconButton from '@material-ui/core/IconButton';
import { withStyles } from '@material-ui/core/styles';
import SearchIcon from '@material-ui/icons/Search';
import InstantSearchIcon from '@material-ui/icons/Sync';
import InstantSearchIconDisabled from '@material-ui/icons/SyncDisabled';
import axios from 'axios'
import QuickPreview from './QuickPreview';
import FilePreview from './FilePreview';
import { throttle, debounce } from "throttle-debounce"
import SearchResultsTable from './SearchResultsTable'
import ProgressIndicator from '../../components/ProgressIndicator'

const SIZE=30;

const styles = theme => ({
  paper: {
    maxWidth: '100%',
    margin: 'auto',
    overflow: 'hidden',
  },
  searchBar: {
    borderBottom: '1px solid rgba(0, 0, 0, 0.12)'
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
  }  
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
      openedFile: "",
      isInlineViewerOpen: false,
      previewedTitle: "",
      isAjaxInProgress: false,
      items: [],
      q: this.props.searchQuery,
      totalResults: 0,
      searchTerms: [],
    };
    this.searchDebounced = debounce(500, this.search);
    this.searchThrottled = throttle(500, this.search);
  }

  handlePreviewClick = (index) => {
    let highlighted_content = (this.state.items[index]['highlight'] && this.state.items[index]['highlight']['content']) ?
          this.state.items[index]['highlight']['content'] : null;
    
    let full_content = (this.state.items[index]['_source']['content'] && this.state.items[index]['_source']['content'].trim() != '') ? [this.state.items[index]['_source']['content'].trim()]  : null
    let preview_content = highlighted_content || full_content

    if (preview_content) {
      this.setState({
        isPreviewOpen: true,
        isInlineViewerOpen: false,
        openedFile: this.state.items[index]['_source'].path.virtual,
        previewedContent: preview_content,
        previewedTitle: this.state.items[index]['_source']['file']['filename']
      })
    }
  }

  handleFilenameClick = (index) => {
    const path = this.state.items[index]['_source'].path.virtual
    this.setState({ isAjaxInProgress: true, isInlineViewerOpen: false, isPreviewOpen: false, openedFile: "" }, () => {
      axios
      .get(`http://localhost:5000/files/is_viewable${path}`)
      .then(res => {
        this.setState({ isAjaxInProgress: false }, () => {
          const isViewable = res.data['is_viewable']
          if (isViewable) {
            this.setState({
              openedFile: path,
              isInlineViewerOpen: true,
              isPreviewOpen: false
            })
          }
          else {
            window.location = `http://localhost:5000/files/download${path}`
          }
        })
      })
    })
  }
  
  componentWillReceiveProps(nextProps) {
    console.log(this._searchBar)
    this.searchWrapper(nextProps.searchTerms, this.search)
    // this._searchBar.value = nextProps.searchTerms
        
  }

  componentDidMount() {
    this.search()
  }

  handlePreviewCloseClick() { 
    this.setState({
      isPreviewOpen: false,
      isInlineViewerOpen: false,
      openedFile: ""
    })
  }

  toggleInstantSearch() {
    this.setState({
      isInstantSearchEnabled: !this.state.isInstantSearchEnabled
    })
  }


  onSearchBarChange = event => {
    if (!this.state.isInstantSearchEnabled) return;
    let searchFunction; 
    if (event.target.value.length < 5) {
      searchFunction = this.searchThrottled;
    } else {
      searchFunction = this.searchDebounced;
    }
    this.searchWrapper(event.target.value, searchFunction)
  }

  onSearchBarKeyPress = event => {
    if (event.key === 'Enter') {
      this.searchWrapper(event.target.value, this.search)
    }
  }

  searchWrapper = (query, searchFunction) => {
    this.setState({ 
      q: query,
      isPreviewOpen: false,
      isInlineViewerOpen: false,
      items: [],
      totalResults: 0,
      searchTerms: query.split(" "),
      openedFile: "" 
    }, searchFunction)
  }

  onLoadMore(from, to) {
    return new Promise((resolve, reject) => {
      this.setState({ 
        isPreviewOpen: false,
        isInlineViewerOpen: false,
        openedFile: "" 
      }, () => { resolve(this.search(from,to)) } )
    })

  }

  search(from=0,to=SIZE) {
    let query = this.state.q || ""
    return new Promise((resolve, reject) => {
      if (query.trim() == "")
      {
        query = {
          "query": {
            "match_all": {}
          },
          "sort": [{ "file.created": { "order": "desc"} }],
          "from": from,
          "size": (to-from)
        }
      } else {
        query = {
          "query": {
            "bool": {
              "should": [
                {
                  "multi_match": {
                    "query": ""+query+"",
                    "fields": [
                      "file.filename^4",
                      "content",
                      "path.real.fulltext^2"
                    ]
                  }
                },
                {
                  "wildcard": {
                    "file.filename": {
                      "value": "*"+query+"*",
                      "boost": 3
                    }
                  }
                }
              ]
            }
          },
          "sort": [
            { "_score": { "order": "desc"} }
          ],
          "from": from,
          "size": (to-from)+1,
          "highlight" : {
            "pre_tags": ["<em class=\"highlight\">"],
            "post_tags": ["</em>"],
            "fragment_size": 0,
            "fields" : {
                "content" : {}
            }
          }
        }
      }

      axios
      .post('http://192.168.1.52:30158/hurradrive_content/_search',  query)
      .then(res => {
        const results = res.data.hits.hits
        this.setState({ totalResults: Math.min(1000, res.data.hits.total), items: this.state.items.concat(results) }, () => { resolve(results) })
      })
    })
  }

  render() {
    const { classes } = this.props;
    let instantSearchIcon = <InstantSearchIcon className={classes.block} color="secondary" onClick={this.toggleInstantSearch.bind(this)} />
    if (!this.state.isInstantSearchEnabled) {
      instantSearchIcon = <InstantSearchIconDisabled className={classes.block} color="inherit" onClick={this.toggleInstantSearch.bind(this)} />
    }

    const { items } = this.state;
    return (
      <Paper className={classes.paper}>
        <QuickPreview open={this.state.isPreviewOpen} onCloseClick={this.handlePreviewCloseClick.bind(this)} content={this.state.previewedContent} title={`Preview (${this.state.previewedTitle})`} />
        <FilePreview open={this.state.isInlineViewerOpen} onCloseClick={this.handlePreviewCloseClick.bind(this)} file={this.state.openedFile} />
        {/* <AppBar className={classes.searchBar} position="static" color="default" elevation={0}>
          <Toolbar variant="dense">
            <Grid container spacing={16} alignItems="center">
              <Grid item>
                <SearchIcon className={classes.block} color="inherit" />
              </Grid>
              <Grid item xs>
                <TextField
                  fullWidth
                  placeholder="Search your files"
                  ref={(child) => { this._searchBar = child }}
                  InputProps={{
                    disableUnderline: true,
                    className: classes.searchInput,
                  }}
                  onChange={this.onSearchBarChange}
                  onKeyPress={this.onSearchBarKeyPress}
                />
              </Grid>
              <Grid item>
                <Tooltip title={this.state.isInstantSearchEnabled ? "Instant Search Enabled (click to disable)" :
                         "Instant Search Disabled (click to enable)" }>
                  <IconButton>
                    {instantSearchIcon}
                  </IconButton>
                </Tooltip>
              </Grid>
            </Grid>
          </Toolbar>
        </AppBar> */}
        <div className={classes.contentWrapper}>
          <SearchResultsTable
          rowCount={this.state.totalResults}
          rowGetter={({ index }) => { return { file: items[index] } } }
          onPreviewClick={this.handlePreviewClick}
          onFilenameClick={this.handleFilenameClick}
          classes={ classes.table }
          onLoadMore={this.onLoadMore.bind(this)}
          searchTerms={ this.state.searchTerms }
          query={this.state.q}
          columns={[
            {
              width: 40,
              label: '',
              dataKey: 'file',
              content: 'downloadButton'
            },
            {
              width: 40,
              label: '',
              dataKey: 'file',
              content: 'openButton'
            },
            {
              width: 40,
              label: '',
              dataKey: 'file',
              content: 'previewButton'
            },
            {
              width: 200,
              flexGrow: 1.0,
              label: 'File',
              dataKey: 'file',
              content: 'filename'
            },
            {
              width: 100,
              label: 'Size',
              dataKey: 'file',
              content: 'size',
              numeric: true
            },
            {
              width: 150,
              label: 'Created',
              dataKey: 'file',
              content: 'created',
              numeric: true
            },
          ]}
        />       
      </div>
      { this.state.isAjaxInProgress && <ProgressIndicator />}
      </Paper>
    );
  }
}

Content.propTypes = {
  classes: PropTypes.object.isRequired,
};

var deepDiffMapper = function() {
  return {
      VALUE_CREATED: 'created',
      VALUE_UPDATED: 'updated',
      VALUE_DELETED: 'deleted',
      VALUE_UNCHANGED: 'unchanged',
      map: function(obj1, obj2) {
          if (this.isFunction(obj1) || this.isFunction(obj2)) {
              throw 'Invalid argument. Function given, object expected.';
          }
          if (this.isValue(obj1) || this.isValue(obj2)) {
              return {
                  type: this.compareValues(obj1, obj2),
                  data: (obj1 === undefined) ? obj2 : obj1
              };
          }

          var diff = {};
          for (var key in obj1) {
              if (this.isFunction(obj1[key])) {
                  continue;
              }

              var value2 = undefined;
              if ('undefined' != typeof(obj2[key])) {
                  value2 = obj2[key];
              }

              diff[key] = this.map(obj1[key], value2);
          }
          for (var key in obj2) {
              if (this.isFunction(obj2[key]) || ('undefined' != typeof(diff[key]))) {
                  continue;
              }

              diff[key] = this.map(undefined, obj2[key]);
          }

          return diff;

      },
      compareValues: function(value1, value2) {
          if (value1 === value2) {
              return this.VALUE_UNCHANGED;
          }
          if (this.isDate(value1) && this.isDate(value2) && value1.getTime() === value2.getTime()) {
              return this.VALUE_UNCHANGED;
          }
          if ('undefined' == typeof(value1)) {
              return this.VALUE_CREATED;
          }
          if ('undefined' == typeof(value2)) {
              return this.VALUE_DELETED;
          }

          return this.VALUE_UPDATED;
      },
      isFunction: function(obj) {
          return {}.toString.apply(obj) === '[object Function]';
      },
      isArray: function(obj) {
          return {}.toString.apply(obj) === '[object Array]';
      },
      isDate: function(obj) {
          return {}.toString.apply(obj) === '[object Date]';
      },
      isObject: function(obj) {
          return {}.toString.apply(obj) === '[object Object]';
      },
      isValue: function(obj) {
          return !this.isObject(obj) && !this.isArray(obj);
      }
  }
}()

export default withStyles(styles)(Content);