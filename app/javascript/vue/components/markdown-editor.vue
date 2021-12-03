<template>
  <div>
    <custom-links
      v-if="showCustomLinks"
      @close="showCustomLinks = false"
      @selected="setCustomLink"/>
    <div ref="markdown">
      <textarea/>
    </div>
  </div>
</template>

<script>

import EasyMDE from 'easymde'
import DOMPurify from 'dompurify'
import 'easymde/dist/easymde.min.css'
import CustomLinks from './markdown/customLinks.vue'
import GetOSKey from 'helpers/getPlatformKey.js'

export default {
  components: { CustomLinks },

  props: {
    modelValue:{
      type: String
    },

    previewClass: String,

    customTheme: {
      type: Boolean,
      default: false
    },

    configs: {
      type: Object,
      default: () => ({})
    }
  },

  emits: [
    'update:modelValue',
    'blur',
    'dblclick'
  ],

  data () {
    return {
      clicks: 0,
      timerClicks: undefined,
      cursorPosition: 0,
      showCustomLinks: false
    }
  },

  created () {
    TW.workbench.keyboard.createLegend(`${GetOSKey()}+shift+l`, 'Open data links modal', 'Markdown editor')
  },

  mounted () {
    this.initialize()
  },

  methods: {
    initialize () {
      const configs = {
        renderingConfig: {
          sanitizerFunction: (renderedHTML) => DOMPurify.sanitize(renderedHTML)
        },
        toolbar: ['bold', 'italic', 'code', 'heading', '|', 'quote', 'unordered-list', 'ordered-list', '|', 'link', 'table', 'preview', {
          name: 'width-auto',
          action: _ => {
            this.openCustomLinks()
          },
          icon: '<span class="word-keep-all">Data links</span>',
          title: 'Data links'
        }]
      }
      Object.assign(configs, this.configs)
      configs.element = configs.element || this.$refs.markdown.firstElementChild
      configs.initialValue = configs.initialValue || this.modelValue
      this.simplemde = new EasyMDE(configs)
      this.customShortcuts()
      const className = this.previewClass || ''
      this.addPreviewClass(className)
      this.bindingEvents()
    },

    bindingEvents () {
      this.simplemde.codemirror.on('change', () => {
        this.$emit('update:modelValue', this.simplemde.value())
      })
      this.simplemde.codemirror.on('blur', () => {
        this.$emit('blur', this.simplemde.value())
      })
      this.simplemde.codemirror.on('mousedown', (cm, ev) => {
        this.clicks++

        if (this.clicks === 1) {
          setTimeout(() => {
            this.cursorPosition = this.simplemde.codemirror.doc.indexFromPos(this.simplemde.codemirror.doc.getCursor())
          }, 100)
        }

        this.timerClicks = setTimeout(() => {
          if (this.clicks > 1) {
            this.$emit('dblclick', this.cursorPosition)
          }
          this.clicks = 0
        }, 300)
      })
    },
    addPreviewClass (className) {
      const wrapper = this.simplemde.codemirror.getWrapperElement()
      const preview = document.createElement('div')
      wrapper.nextSibling.className += ` ${className}`
      preview.className = `editor-preview ${className}`
      wrapper.appendChild(preview)
    },
    setCustomLink (item) {
      const cm = this.simplemde.codemirror
      const selectedText = cm.getSelection()
      const text = selectedText || item.label
      const output = `[${text}](${item.link})`

      cm.replaceSelection(output)
    },
    customShortcuts () {
      const codemirror = this.simplemde.codemirror
      const keys = codemirror.getOption('extraKeys')
      const key = GetOSKey().charAt(0).toUpperCase() + GetOSKey().slice(1)
      keys[`Shift-${key}-L`] = () => {
        this.openCustomLinks()
      }
      codemirror.setOption('extraKeys', keys)
    },
    openCustomLinks () {
      this.showCustomLinks = true
    },

    setFocus () {
      const codemirror = this.simplemde.codemirror

      codemirror.focus()
      codemirror.setCursor(codemirror.lineCount(), 0)
    }
  },
  unmounted () {
    this.simplemde = null
  },
  watch: {
    modelValue (val) {
      if (val === this.simplemde.value()) return
      this.simplemde.value(val)
    }
  }
}
</script>
