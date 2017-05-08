Rails.application.config.tap do |c|
  c.browserify_rails.commandline_options = "-t [ vueify --extensions .vue ] -t [ babelify --presets [ es2015 stage-0 ] --extensions .js --plugins [ syntax-async-functions transform-regenerator ] ]"
end