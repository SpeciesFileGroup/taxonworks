const { DefinePlugin } = require('webpack')
const openInEditor = require('launch-editor-middleware')

module.exports = (webpackConfig) => {
  if (!webpackConfig.devServer) return {}

  const { server, host, port } = webpackConfig.devServer

  return {
    devServer: {
      setupMiddlewares: (middlewares, devServer) => {
        if (!devServer) throw new Error('webpack-dev-server is not defined')

        devServer.app.use('/__open-in-editor', (req, res, next) => {
          res.setHeader('Access-Control-Allow-Origin', '*')
          res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS')
          res.setHeader('Access-Control-Allow-Headers', 'Content-Type')

          // give launch-editor-middleware an absolute url (already fixed to not
          // be required in 2.11.1)
          const absoluteUrlReq = {
            ...req,
            url: `http://localhost${req.url}`
          }
          return openInEditor()(absoluteUrlReq, res, next)
        })

        return middlewares
      }
    },
    plugins: [
      new DefinePlugin({
        __VUE_DEVTOOLS_CONFIG__: JSON.stringify({
          openInEditorHost: `${server}://${host}:${port}/`
        })
      })
    ]
  }
}
