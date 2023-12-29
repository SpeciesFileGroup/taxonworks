const { VueLoaderPlugin } = require('vue-loader')
const { DefinePlugin } = require('webpack')

module.exports = {
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: 'vue-loader'
      }
    ]
  },
  plugins: [
    new VueLoaderPlugin(),
    new DefinePlugin({
      __VUE_PROD_DEVTOOLS__: 'false'
    })
  ],
  resolve: {
    extensions: ['.css', '.vue']
  }
}
