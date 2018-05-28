const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const vue =  require('./loaders/vue')
const styl =  require('./loaders/styl')

environment.plugins.append('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.append('vue', vue)
environment.loaders.append('styl', styl)

console.log("Starting")
module.exports = environment
