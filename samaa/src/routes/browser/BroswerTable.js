import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { withStyles, withTheme } from '@material-ui/core/styles';
import TableCell from '@material-ui/core/TableCell';
import TableSortLabel from '@material-ui/core/TableSortLabel';
import {
  AutoSizer,
  Column,
  SortDirection,
  Table,
  InfiniteLoader,
} from 'react-virtualized';
import Tooltip from '@material-ui/core/Tooltip';
import IconButton from '@material-ui/core/IconButton';
import Moment from 'react-moment';
import Utils from '../../utils'
import OpenIcon from '@material-ui/icons/OpenInNew';
import DownloadIcon from '@material-ui/icons/GetApp';
import FilterIcon from '@material-ui/icons/FilterList';

const STATUS_LOADING = 1;
const STATUS_LOADED = 2;

const styles = theme => ({
  table: {
    fontFamily: theme.typography.fontFamily,
  },
  flexContainer: {
    display: 'flex',
    alignItems: 'center',
    // boxSizing: 'border-box',
  },
  tableRow: {
    cursor: 'pointer',
  },
  tableRowHover: {
    '&:hover': {
      backgroundColor: theme.palette.grey[200],
    },
  },
  tableCellBold: {
    fontWeight: '500',
  },
  placeholder: {
    display: 'inline-block',
    height: '1em',
    backgroundColor: '#DDD',
  },
  tableCell: {
    flex: 1,
  },
  tableHeader: {
    flex: 1,
    backgroundColor: theme.palette.grey[800],
    color: 'white',
  },
  filterIcon: {
    color: 'white',
  },
  noClick: {
    cursor: 'initial',
  },
  button: {
    '&:hover': {
      backgroundColor: 'transparent',
    },
  },
});

class BrowserTable extends React.PureComponent {
  constructor(props) {
    super(props);
    this.state = {
      searchTerms: [],
      query: '',
      loadedRowCount: 0,
      loadedRowsMap: {},
      loadingRowCount: 0,
    };

    this._timeoutIdMap = {};

    this._clearData = this._clearData.bind(this);
    this._isRowLoaded = this._isRowLoaded.bind(this);
    this._loadMoreRows = this._loadMoreRows.bind(this);
    this._rowRenderer = this._rowRenderer.bind(this);
  }
  componentWillReceiveProps = nextProps => {
    if (this.props.query != nextProps.query) {
      this.setState(
        {
          searchTerms: nextProps.searchTerms,
          query: nextProps.query,
        },
        this._clearData,
      );
    }
  };

  getRowClassName = ({ index }) => {
    const { classes, rowClassName, onRowClick } = this.props;

    return classNames(classes.tableRow, classes.flexContainer, rowClassName, {
      [classes.tableRowHover]: index !== -1,
    });
  };

  cellRenderer = cellType => ({
    cellData,
    columnIndex = null,
    rowIndex,
    row,
  }) => {
    const { columns, classes, rowHeight, onRowClick, theme } = this.props;
    const { primary, secondary } = theme.palette.text;
    if (!cellData) {
      return (
        <TableCell
          component="div"
          className={classNames(classes.tableCell, classes.flexContainer)}
          variant="body"
          style={{ height: rowHeight }}
          onClick={() => this.props.onFilenameClick(rowIndex)}
        >
          <div className={classes.placeholder} style={{ width: 200 }} />
        </TableCell>
      );
    }
    switch (cellType) {
      case 'filename': {
        return (
          <TableCell
            component="div"
            className={classNames(
              classes.tableCell,
              classes.flexContainer,
              classes.tableCellBold,
            )}
            variant="body"
            style={{
              height: rowHeight,
              color: cellData.name == '..' ? '#960000' : 'black',
            }}
            onClick={() => this.props.onFilenameClick(rowIndex)}
          >
            <span
              className={
                cellData.type == 'source_drive'
                  ? 'far fa-hdd fa-2x'
                  : `fiv-sqo fiv-icon-blank fiv-icon-${cellData.type}`
              }
              style={{ marginRight: '0.5em' }}
            >
              {cellData.name == '..' && (
                <i
                  className="fas fa-arrow-left fa-xs"
                  style={{
                    fontSize: '0.4em',
                    paddingBottom: '0.8em',
                    paddingLeft: '0.3em',
                    color: '#af9600',
                  }}
                />
              )}
            </span>
            {cellData.name == '..' ? 'Back' : cellData.name}
          </TableCell>
        );
      }
      case 'downloadButton': {
        if (cellData.type == 'folder' || cellData.type.indexOf('source_') == 0)
          return (
            <TableCell
              style={{ height: rowHeight }}
              variant="body"
              className={classNames(classes.tableCell, classes.flexContainer, {
                [classes.noClick]: onRowClick == null,
              })}
            />
          );
        return (
          <TableCell
            component="div"
            className={classNames(classes.tableCell, classes.flexContainer, {
              [classes.noClick]: onRowClick == null,
            })}
            variant="body"
            style={{ height: rowHeight }}
            padding="none"
          >
            <Tooltip title="Donwload File">
              <IconButton href="http://192.168.1.2:5000/files/download">
                <DownloadIcon color="inherit" color="primary" />
              </IconButton>
            </Tooltip>
          </TableCell>
        );
      }
      case 'openButton': {
        return (
          <TableCell
            component="div"
            className={classNames(classes.tableCell, classes.flexContainer, {
              [classes.noClick]: onRowClick == null,
            })}
            variant="body"
            style={{ height: rowHeight }}
            padding="none"
          >
            <Tooltip title="Open in New Window">
              <IconButton
                href="http://192.168.1.2:5000/files/view"
                target="_blank"
              >
                <OpenIcon color="inherit" color="primary" />
              </IconButton>
            </Tooltip>
          </TableCell>
        );
      }
      case 'size': {
        return (
          <TableCell
            component="div"
            className={classNames(classes.tableCell, classes.flexContainer, {
              [classes.noClick]: onRowClick == null,
            })}
            variant="body"
            style={{ height: rowHeight }}
            padding="none"
            align="right"
          >
            {cellData.type.indexOf('source_') != 0 &&
              Utils.humanFileSize(cellData.filesize)}
          </TableCell>
        );
      }
      case 'created': {
        return (
          <TableCell
            component="div"
            className={classNames(classes.tableCell, classes.flexContainer, {
              [classes.noClick]: onRowClick == null,
            })}
            variant="body"
            style={{ height: rowHeight, paddingRight: '10px' }}
            padding="none"
            align="right"
          >
            <Moment format="YYYY/MM/DD hh:mm a " />
          </TableCell>
        );
      }
    }
  };

  headerRenderer = ({ label, columnIndex, dataKey, sortBy, sortDirection }) => {
    const { headerHeight, columns, classes, sort } = this.props;
    const direction = {
      [SortDirection.ASC]: 'asc',
      [SortDirection.DESC]: 'desc',
    };

    const filterIcon =
      columnIndex == 0 ? (
        <IconButton>
          <div className={classes.filterIcon}>
            <Tooltip title="Filter Results">
              <FilterIcon />
            </Tooltip>
          </div>
        </IconButton>
      ) : (
        ''
      );

    const inner =
      !columns[columnIndex].disableSort && sort != null ? (
        <TableSortLabel
          active={dataKey === sortBy}
          direction={direction[sortDirection]}
        >
          {[filterIcon, label]}
        </TableSortLabel>
      ) : (
        [label]
      );

    return (
      <TableCell
        component="div"
        className={classNames(
          classes.tableHeader,
          classes.flexContainer,
          classes.noClick,
        )}
        variant="head"
        style={{ height: headerHeight }}
        align={columns[columnIndex].numeric || false ? 'right' : 'left'}
      >
        {inner}
      </TableCell>
    );
  };

  _isRowLoaded({ index }) {
    // const { loadedRowsMap } = this.state;
    return true;
  }

  _loadMoreRows({ startIndex, stopIndex }) {
    const { loadedRowsMap, loadingRowCount } = this.state;
    const increment = stopIndex - startIndex + 1;

    for (let i = startIndex; i <= stopIndex; i++) {
      loadedRowsMap[i] = STATUS_LOADING;
    }

    this.setState({
      loadingRowCount: loadingRowCount + increment,
    });

    this.props.onLoadMore(startIndex, stopIndex).then(results => {
      const { loadedRowCount, loadingRowCount } = this.state;

      for (let i = startIndex; i <= stopIndex; i++) {
        loadedRowsMap[i] = STATUS_LOADED;
      }

      this.setState({
        loadingRowCount: loadingRowCount - increment,
        loadedRowCount: loadedRowCount + increment,
      });

      promiseResolver();
    }, 1000 + Math.round(Math.random() * 2000));

    let promiseResolver;

    return new Promise(resolve => {
      promiseResolver = resolve;
    });
  }

  _rowRenderer({ index, key, style }) {
    const { list } = this.context;
    const { loadedRowsMap } = this.state;

    const row = list.get(index);
    let content;

    if (loadedRowsMap[index] === STATUS_LOADED) {
      content = row.name;
    } else {
      content = (
        <div className={styles.placeholder} style={{ width: row.size }} />
      );
    }

    return (
      <div className={styles.row} key={key} style={style}>
        {content}
      </div>
    );
  }

  _clearData() {
    this.setState(
      {
        loadedRowCount: 0,
        loadedRowsMap: {},
        loadingRowCount: 0,
      },
      () => {
        this._infiniteLoader.resetLoadMoreRowsCache(),
          this._table.scrollToRow(0);
      },
    );
  }

  render() {
    const { classes, columns, rowCount, ...tableProps } = this.props;
    return (
      <InfiniteLoader
        isRowLoaded={this._isRowLoaded}
        loadMoreRows={this._loadMoreRows}
        rowCount={rowCount}
        ref={child => {
          this._infiniteLoader = child;
        }}
      >
        {({ onRowsRendered, registerChild }) => (
          <AutoSizer disableHeight>
            {({ width }) => (
              <Table
                className={classes.table}
                height={550}
                width={width}
                rowCount={rowCount}
                ref={child => {
                  this._table = child;
                  registerChild(child);
                }}
                onRowsRendered={onRowsRendered}
                {...tableProps}
                rowClassName={this.getRowClassName}
              >
                {columns.map(
                  (
                    {
                      cellContentRenderer = null,
                      className,
                      dataKey,
                      content,
                      ...other
                    },
                    index,
                  ) => {
                    const renderer = this.cellRenderer(content);
                    return (
                      <Column
                        key={dataKey}
                        headerRenderer={headerProps =>
                          this.headerRenderer({
                            ...headerProps,
                            columnIndex: index,
                          })
                        }
                        className={classNames(classes.flexContainer, className)}
                        cellRenderer={renderer}
                        dataKey={dataKey}
                        {...other}
                      />
                    );
                  },
                )}
              </Table>
            )}
          </AutoSizer>
        )}
      </InfiniteLoader>
      //     </div>
      // </div>);
    );
  }
}

BrowserTable.propTypes = {
  classes: PropTypes.object.isRequired,
  columns: PropTypes.arrayOf(
    PropTypes.shape({
      cellContentRenderer: PropTypes.func,
      dataKey: PropTypes.string.isRequired,
      width: PropTypes.number.isRequired,
    }),
  ).isRequired,
  searchTerms: PropTypes.array.isRequired,
  headerHeight: PropTypes.number,
  onRowClick: PropTypes.func,
  rowClassName: PropTypes.string,
  rowHeight: PropTypes.oneOfType([PropTypes.number, PropTypes.func]),
  sort: PropTypes.func,
};

BrowserTable.defaultProps = {
  headerHeight: 45,
  rowHeight: 40,
};

export default withTheme()(withStyles(styles)(BrowserTable));
