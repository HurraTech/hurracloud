/**
 * React Starter Kit (https://www.reactstarterkit.com/)
 *
 * Copyright © 2014-present Kriasoft, LLC. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE.txt file in the root directory of this source tree.
 */

import React from 'react';
import Layout from '../../components/Layout/Layout';
import SearchPage from './SearchPage';
import QueryString from 'query-string';
import history from '../../history';

class HomePage extends React.Component {
  constructor(props) {
    super(props);
    const queryString = QueryString.parse(history.location.search);
    this.state = {
      searchQuery: queryString.q,
    };
  }

  onNewSearch(query) {
    this.setState({
      searchQuery: query,
    });
  }

  render() {
    return (
      <Layout onNewSearch={this.onNewSearch.bind(this)}>
        <SearchPage searchTerms={this.state.searchQuery} />
      </Layout>
    );
  }
}

async function action() {
  return {
    title: 'HurraCloud',
    chunks: ['search'],
    component: <HomePage />,
  };
}

export default action;
