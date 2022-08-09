<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="showModal = true">
      Edit custom style
    </button>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <template #header>
        <h3>Customize style</h3>
      </template>
      <template #body>
        <div
          class="preview-box horizontal-center-content middle">
          <pre :style="customStyle">This is my label


 With a different style</pre>
        </div>
      </template>
      <template #footer>
        <fieldset>
          <legend>Style</legend>
          <div class="flex-separate align-end">
            <div class="field label-above">
              <input
                type="text"
                v-model="styleName"
                placeholder="Style name...">
            </div>

            <div class="margin-small-bottom">
              <v-btn
                class="margin-small-right"
                medium
                color="primary"
                @click="exportStyle"
              >
                Export
              </v-btn>
              <v-btn
                medium
                color="primary"
                @click="$refs.selectedFile.click()"
              >
                Import
              </v-btn>
              <input
                type="file"
                ref="selectedFile"
                class="d-none"
                accept="text/json"
                @change="loadStyle"
              >
            </div>
          </div>
        </fieldset>
        <div
          class="options">
          <div class="horizontal-left-content align-start">
            <fieldset>
              <legend>Font</legend>
              <label>Text align</label>
              <select
                v-model="options.font.textAlign"
                class="normal-input input-size">
                <option value="left">Left</option>
                <option value="right">Right</option>
                <option value="center">Center</option>
                <option value="justify">Justify</option>
              </select>
              <label>Size</label>
              <input
                type="number"
                v-model="options.font.size"
                class="input-size">
              <label>Line height</label>
              <input
                type="number"
                class="input-size"
                min="0"
                step="10"
                v-model="options.font.lineHeight">
              <label>Font weight</label>
              <select
                v-model="options.font.weight"
                class="normal-input input-size">
                <option value="100">Light</option>
                <option value="500">Normal</option>
                <option value="700">Bold</option>
              </select>
              <label>Font family</label>
              <select
                v-model="options.font.fontFamily"
                class="normal-input input-size">
                <option
                  v-for="font in fontTypes"
                  :key="font"
                  :value="font">{{ font }}
                </option>
              </select>
            </fieldset>
            <fieldset>
              <legend>Border</legend>
              <label>Style</label>
              <select
                v-model="options.border.type"
                class="normal-input input-size">
                <option value="dashed">Dashed</option>
                <option value="double">Double</option>
                <option value="solid">Solid</option>
              </select>
              <label>Size</label>
              <input
                type="number"
                class="input-size"
                min="0"
                v-model="options.border.size">
              <label>Radius</label>
              <input
                type="number"
                class="input-size"
                min="0"
                v-model="options.border.radius">
              <label>Color</label>
              <input
                type="color"
                class="input-size"
                v-model="options.border.color">
            </fieldset>
            <fieldset>
              <legend>Padding</legend>
              <div>
                <div class="separate-right">
                  <label>Top</label>
                  <input
                    type="number"
                    min="0"
                    v-model="options.padding.top"
                    class="input-size">
                </div>
                <div class="separate-right">
                  <label>Right</label>
                  <input
                    type="number"
                    min="0"
                    v-model="options.padding.right"
                    class="input-size">
                </div>
                <div class="separate-right">
                  <label>Bottom</label>
                  <input
                    type="number"
                    min="0"
                    v-model="options.padding.bottom"
                    class="input-size">
                </div>
                <div class="separate-right">
                  <label>Left</label>
                  <input
                    type="number"
                    min="0"
                    v-model="options.padding.left"
                    class="input-size">
                </div>
              </div>
            </fieldset>
            <fieldset class="full_width">
              <legend>JSON style</legend>
              <pre>{{ jsonStyle }}</pre>
            </fieldset>
          </div>
        </div>
      </template>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal'
import VBtn from 'components/ui/VBtn/index.vue'
import { downloadTextFile } from 'helpers/files.js'

export default {
  components: {
    ModalComponent,
    VBtn
  },

  emits: [
    'newStyle',
    'newName'
  ],

  computed: {
    customStyle() {
      const style = {}
      style['border'] = `${this.options.border.size}px ${this.options.border.type} ${this.options.border.color}`
      style['border-radius'] = `${this.options.border.radius}px`

      style['font-size'] = `${this.options.font.size}pt`
      style['font-weight'] = this.options.font.weight
      style['font-family'] = this.options.font.fontFamily

      style['line-height'] = `${this.options.font.lineHeight}%`
      style['text-align'] = this.options.font.textAlign

      style['padding'] = `${this.options.padding.top}px ${this.options.padding.right}px ${this.options.padding.bottom}px ${this.options.padding.left}px`

      return style
    },
    cssFormat() {
      return `border: ${this.options.border.size}px ${this.options.border.type} ${this.options.border.color}; 
      border-radius: ${this.options.border.radius}px;
      font-size: ${this.options.font.size}pt;
      font-weight: ${this.options.font.weight};
      font-family: ${this.options.font.fontFamily};
      line-height: ${this.options.font.lineHeight}%;
      text-align: ${this.options.font.textAlign};
      white-space: pre;
      padding: ${this.options.padding.top}px ${this.options.padding.right}px ${this.options.padding.bottom}px ${this.options.padding.left}px;
      `
    },

    jsonStyle () {
      return JSON.stringify({
        name: this.styleName,
        style: this.options
      }, null, 2)
    }
  },

  data () {
    return {
      styleName: '',
      options: {
        border: {
          size: 0,
          type: 'dashed',
          radius: 0,
          color: '#000000'
        },
        font: {
          size: 8,
          lineHeight: 100,
          textAlign: 'center',
          weight: '500',
          fontFamily: 'Times'
        },
        padding: {
          top: 0,
          right: 0,
          bottom: 0,
          left: 0
        }
      },
      showModal: false,
      fontTypes: ['Times', 'Arial', 'Helvetica', 'Verdana', 'monospace']
    }
  },

  watch: {
    customStyle () {
      this.setStyle()
    },

    styleName () {
      this.$emit('newName', this.styleName)
    }
  },

  methods: {
    setStyle () {
      this.$emit('newStyle', this.cssFormat)
    },

    exportStyle () {
      const fileName = this.styleName || 'customStyle.json'

      downloadTextFile(this.jsonStyle, 'text/json', `${fileName}.json`)
    },

    loadStyle (e) {
      const files = e.target.files

      if (e.target.files.length) {
        const fr = new FileReader()

        fr.onload = e => {
          const result = JSON.parse(e.target.result)

          this.options = {
            ...this.options,
            ...result.style
          }

          this.styleName = result.name
        }

        fr.readAsText(files.item(0))
      }
    }
  }
}
</script>

<style lang="scss" scoped>
  :deep(.modal-container) {
   width: 600px;
  }
  .preview-box {
    min-height: 200px;
  }
  pre {
    background-color: #F5F5F5;
    width: auto;
  }
  .options {
    .input-size {
      width: 70px;
    }
    label {
      display: block;
    }
  }
</style>
