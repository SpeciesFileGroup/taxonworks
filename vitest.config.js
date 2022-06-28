import { defineConfig } from 'vitest/config'

import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

export default defineConfig({
  resolve: {
    alias: {
      helpers: resolve(__dirname, './app/javascript/vue/helpers')
    }
  },

  plugins: [vue()],

  test: {
    environment: 'jsdom',
    globals: true,
    include: ['./app/javascript/**/*.{test,spec}.{js,mjs,cjs,ts,mts,cts,jsx,tsx}'],
    setupFiles: 'app/javascript/setupTests.js'
  }
})
