<template>
  <div id="markdown-editor">
    <textarea/>
  </div>
</template>

<script>
export default {
  template: '',
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
      default () {
        return {
        }
      }
    }
  },
  data: function () {
    return {
      clicks: 0,
      timerClicks: undefined,
      cursorPosition: 0
    }
  },
  ready () {
    this.initialize()
    this.syncValue()
  },
  mounted () {
    this.initialize()
  },
  methods: {
    initialize () {
      let configs = {}
      Object.assign(configs, this.configs)
      configs.element = configs.element || this.$el.firstElementChild
      configs.initialValue = configs.initialValue || this.value
      this.simplemde = new SimpleMDE(configs)
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
    syncValue () {
      this.simplemde.codemirror.on('change', () => {
        this.value = this.simplemde.value()
      })
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
