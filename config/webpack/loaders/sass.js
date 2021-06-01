module.exports = {
  test: /\.scss$/,
  exclude: /\.module\.scss$/,
  use: [
    {
      loader: 'style-loader'
    },
    {
      loader: 'css-loader',
      options: {
        importLoaders: 1,
        modules: {
          compileType: 'icss'
        }
      }
    },
    {
      loader: 'sass-loader'
    }
  ]
}
