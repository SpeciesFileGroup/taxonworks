// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.

const { generateWebpackConfig, merge } = require('shakapacker')
const vueConfig = require('./rules/vue')
const path = require('node:path')

const customConfig = {
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

module.exports = merge(vueConfig, customConfig, generateWebpackConfig())
