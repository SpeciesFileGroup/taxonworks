const { generateRspackConfig, merge } = require('shakapacker/rspack')
const vueConfig = require('./rules/vue')
const devServerConfig = require('./rules/devServer')
const path = require('node:path')
const rspack = require('@rspack/core')
const rspackConfig = generateRspackConfig()
const pdfjsDistPath = path.dirname(require.resolve('pdfjs-dist/package.json'))

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
  },
  plugins: [
    new rspack.CopyRspackPlugin({
      patterns: [
        {
          from: path.join(pdfjsDistPath, 'wasm'),
          to: 'pdfjs/wasm'
        },
        {
          from: path.join(pdfjsDistPath, 'iccs'),
          to: 'pdfjs/iccs'
        },
        {
          from: path.join(pdfjsDistPath, 'cmaps'),
          to: 'pdfjs/cmaps'
        },
        {
          from: path.join(pdfjsDistPath, 'standard_fonts'),
          to: 'pdfjs/standard_fonts'
        }
      ]
    })
  ]
}

module.exports = merge(
  rspackConfig,
  vueConfig,
  devServerConfig(rspackConfig),
  customConfig
)
