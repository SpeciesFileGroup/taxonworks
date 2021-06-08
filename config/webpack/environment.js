const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const sass = require('./loaders/sass')
const vue = require('./loaders/vue')
const styl = require('./loaders/styl')

const customConfig = {
  resolve: {
    alias: {
      vue: '@vue/compat'
    }
  }
}

// environment.config.merge(customConfig)

environment.plugins.append('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.append('vue', vue)
environment.loaders.append('sass', sass)
environment.loaders.append('styl', styl)

module.exports = environment
