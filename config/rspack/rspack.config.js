const { generateRspackConfig, merge } = require('shakapacker/rspack')
const vueConfig = require('./rules/vue')
const devServerConfig = require('./rules/devServer')
const path = require('node:path')
const rspack = require('@rspack/core')
const rspackConfig = generateRspackConfig()

const customConfig = {
  lazyCompilation: false,
  optimization: {
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          priority: -10,
          reuseExistingChunk: true
        }
      }
    },
    minimize: true,
    minimizer: [
      new rspack.SwcJsMinimizerRspackPlugin(),
      new rspack.LightningCssMinimizerRspackPlugin()
    ]
  },
  resolve: {
    extensions: ['.vue', '.css', '.scss', '.js'],
    alias: {
      '@': path.resolve(__dirname, '..', '..', 'app/javascript/vue')
    }
  },
  output: {
    environment: {
      asyncFunction: true
    }
  }
}

module.exports = merge(
  rspackConfig,
  vueConfig,
  devServerConfig(rspackConfig),
  customConfig
)
