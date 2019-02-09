import React from 'react';
import Layout from '../../components/Layout/Layout';
import Browser from './Browser';
import history from '../../history';

class BrowserPage extends React.Component {
  constructor(props) {
    super(props);
    console.log("BrowserPage history", history.location.pathname.substring("/browse/".length))
    this.state = {
      path: history.location.pathname.substring("/browse/".length),
    };
  }

  onPartitionClick(path) {
    console.log("We've been called back! :)", path)
    this.setState({
      path: path.substring("/browse/".length)
    }, () => {
      console.log("We just set our state to ", this.state.path)
    })
  }

  render() {
    return (
      <Layout onPartitionClick={this.onPartitionClick.bind(this)}>
        <Browser path={this.state.path} />
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
