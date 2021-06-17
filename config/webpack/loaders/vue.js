module.exports = {
  test: /\.vue(\.erb)?$/,
  use: [{
    loader: 'vue-loader',
  /*   options: {
      compilerOptions: {
        compatConfig: {
          MODE: 2,
          RENDER_FUNCTION: false,
          COMPONENT_V_MODEL: false
        }
      }
    } */
  }]
}
