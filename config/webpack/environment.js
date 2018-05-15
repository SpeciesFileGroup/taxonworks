const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const vue =  require('./loaders/vue')
const styl =  require('./loaders/styl')

environment.plugins.append('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.append('vue', vue)
environment.loaders.append('styl', styl)

environment.loaders.get('sass').use.splice(-1, 0, {
  loader: 'resolve-url-loader',
});

module.exports = environment
