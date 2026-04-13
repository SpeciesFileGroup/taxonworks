import js from '@eslint/js'
import pluginVue from 'eslint-plugin-vue'
import prettier from 'eslint-config-prettier'
import globals from 'globals'

export default [
  js.configs.recommended,
  ...pluginVue.configs['flat/strongly-recommended'],
  prettier,
  {
    languageOptions: {
      globals: {
        TW: 'writable',
        jquery: 'readonly',
        ...globals.browser
      }
    }
  }
]
