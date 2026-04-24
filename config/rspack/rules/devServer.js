const { config: shakapackerConfig } = require('shakapacker')
const { DefinePlugin } = require('@rspack/core')
const openInEditor = require('launch-editor-middleware')

module.exports = (webpackConfig) => {
  if (!webpackConfig.devServer) return {}

  const { server, host, port } = webpackConfig.devServer

  return {
    devtool: 'source-map',
    devServer: {
      devMiddleware: {
        publicPath: shakapackerConfig.publicPath
      },
      historyApiFallback: { disableDotRule: true },
      static: {
        publicPath: shakapackerConfig.outputPath,
        watch: false
      },
      client: {
        overlay: {
          errors: true,
          warnings: false,
          runtimeErrors: (error) =>
            !error.message.includes('e.location.reload is not a function')
        }
      },

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
      }),
      new DefinePlugin({
        __RSPACK_WS_URL__: JSON.stringify(`${server}://${host}:${port}/ws`)
      })
    ]
  }
}
