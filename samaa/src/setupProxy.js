const { createProxyMiddleware } = require('http-proxy-middleware');
module.exports = function(app) {
  app.use(
    '/jawhar',
    createProxyMiddleware({
      target: 'http://jawhar:3000',
      changeOrigin: true,
      pathRewrite: {
        "^/jawhar": "",
      }      
    })
  );
};
