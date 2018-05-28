process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')
console.log("Loading test configuration")
module.exports = environment.toWebpackConfig()
