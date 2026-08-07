import { vHelp } from '@/directives'

const HelpSystem = {
  install(app, options = {}) {
    const languages = options.languages || {}
    const defaultLanguage = options.default || Object.keys(languages)[0]

    app.directive('help', {
      ...vHelp,
      helpData: languages[defaultLanguage]
    })
  }
}

export default HelpSystem
