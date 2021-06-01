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
import GetOSKey from 'helpers/getMacKey.js'

export default {
  components: {
    CustomLinks
  },
  props: {
    value: String,
    previewClass: String,
    customTheme: {
      type: Boolean,
      default () {
        return false
      }
    },
    configs: {
      type: Object,
      default: () => {}
    }
  },
  data: function () {
    return {
      clicks: 0,
      timerClicks: undefined,
      cursorPosition: 0,
      showCustomLinks: false
    }
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
          action: (editor) => {
            // this.openCustomLinks()
          },
          icon:'<span class="word-keep-all subtle">Data links</span>',
          title: 'Data links',
          disable: true
        }]
      }
      Object.assign(configs, this.configs)
      configs.element = configs.element || this.$refs.markdown.firstElementChild
      configs.initialValue = configs.initialValue || this.value
      this.simplemde = new EasyMDE(configs)
      this.customShortcuts()
      const className = this.previewClass || ''
      this.addPreviewClass(className)
      this.bindingEvents()
    },
    bindingEvents () {
      this.simplemde.codemirror.on('change', () => {
        this.$emit('input', this.simplemde.value())
      })
      this.simplemde.codemirror.on('blur', () => {
        this.$emit('blur', this.simplemde.value())
      })
      this.simplemde.codemirror.on('mousedown', (cm, ev) => {
        let that = this

        this.clicks++

        if (this.clicks == 1) {
          setTimeout(function () {
            that.cursorPosition = that.simplemde.codemirror.doc.indexFromPos(that.simplemde.codemirror.doc.getCursor())
          }, 100)
        }

        this.timerClicks = setTimeout(function () {
          if (that.clicks > 1) {
            that.$emit('dblclick', that.cursorPosition)
          }
          that.clicks = 0
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
      var cm = this.simplemde.codemirror
      var output = ''
      var selectedText = cm.getSelection()
      var text = selectedText || item.label

      output = `[${text}](${item.link})`
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
    }
  },
  destroyed () {
    this.simplemde = null
  },
  watch: {
    value (val) {
      if (val === this.simplemde.value()) return
      this.simplemde.value(val)
    }
  }
}
</script>
