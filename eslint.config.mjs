import js from '@eslint/js'
import pluginVue from 'eslint-plugin-vue'
import prettier from 'eslint-config-prettier'

export default [
  js.configs.recommended,
  ...pluginVue.configs['flat/strongly-recommended'],
  prettier,
  {
    languageOptions: {
      globals: {
        TW: 'writable',
        jquery: 'readonly'
      }
    }
  }
]
