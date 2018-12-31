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

class HomePage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      searchQuery: '',
    };
  }

  onNewSearch(query) {
    this.setState({
      searchQuery: query,
    });
  }

  render() {
    const onNewSearch = this.onNewSearch.bind(this);
    return (
      <Layout onNewSearch={onNewSearch}>
        <SearchPage searchTerms={this.state.searchQuery} />
      </Layout>
    );
  }
}

async function action() {
  return {
    title: 'HurraCloud',
    chunks: ['home'],
    component: <HomePage />,
  };
}

export default action;
