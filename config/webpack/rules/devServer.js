const { DefinePlugin } = require('webpack')
const openInEditor = require('launch-editor-middleware')

module.exports = (webpackConfig) => {
  const { server, host, port } = webpackConfig.devServer

  return {
    devServer: {
      setupMiddlewares: (middlewares, devServer) => {
        if (!devServer) throw new Error('webpack-dev-server is not defined')

        devServer.app.use('/__open-in-editor', (req, res, next) => {
          res.setHeader('Access-Control-Allow-Origin', '*')
          res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS')
          res.setHeader('Access-Control-Allow-Headers', 'Content-Type')

          return openInEditor()(req, res, next)
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
