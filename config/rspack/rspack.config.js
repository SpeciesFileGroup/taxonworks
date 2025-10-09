const { generateRspackConfig, merge } = require('shakapacker/rspack')
const vueConfig = require('./rules/vue')
const devServerConfig = require('./rules/devServer')
const path = require('node:path')

const rspackConfig = generateRspackConfig()

const customConfig = {
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
    }
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
