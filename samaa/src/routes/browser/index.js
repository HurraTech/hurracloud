import React from 'react';
import Layout from '../../components/Layout/Layout';
import Browser from './Browser';

class BrowserPage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      searchQuery: '',
    };
  }

  render() {
    return (
      <Layout>
        <Browser />
      </Layout>
    );
  }
}

async function action() {
  return {
    title: 'HurraCloud',
    chunks: ['browser'],
    component: <BrowserPage />,
  };
}

export default action;
