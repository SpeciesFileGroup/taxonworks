// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.

const { webpackConfig, merge } = require('shakapacker')
const vueConfig = require('./rules/vue')

const customConfig = {
  resolve: {
    extensions:  ['.vue', '.css', '.scss', '.js']
  }
}


module.exports = merge(vueConfig, webpackConfig)
