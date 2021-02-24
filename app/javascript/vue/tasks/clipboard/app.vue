<template>
  <div
    id="vue-clipboard-app"
    class="full_width">
    <ul class="slide-panel-category-content">
      <li
        v-for="(clip, index) in clipboard"
        :key="index"
        class="slide-panel-category-item">
        <div class="full_width padding-large-right">
          <p>Shortcut: <b>{{ keyCode[actionKey] }} {{ isLinux ? '+ Shift' : '' }} + {{ index }}</b></p>
          <div class="middle">
            <textarea
              class="full_width"
              rows="5"
              v-model="clipboard[index]"
              @blur="saveClipboard"/>
          </div>
        </div>
      </li>
    </ul>
    <p class="slide-panel-category-content">
      Use <b>{{ keyCode[actionKey] }} + C + Number</b> to copy a text to the clipboard box
    </p>
  </div>
</template>
<script>

import { GetClipboard, UpdateClipboard } from './request/resources'

export default {
  computed: {
    actionKey() {
      return (navigator.platform.indexOf('Mac') > -1 ? 17 : 18)
    },
    isLinux () {
      return window.navigator.userAgent.indexOf('Linux') > -1
    }
  },
  data() {
    return {
      clipboard: {
        1: '',
        2: '',
        3: '',
        4: '',
        5: ''
      },
      keyCode: {
        17: 'Ctrl',
        18: 'Alt'
      },
      keys: []
    }
  },
  mounted () {
    document.addEventListener('turbolinks:load', (event) => {
      document.removeEventListener('keydown', this.KeyPress)
      document.removeEventListener('keyup', this.removeKey)
    })
    document.addEventListener('keydown', this.KeyPress)
    document.addEventListener('keyup', this.removeKey)
    GetClipboard().then(response => {
      Object.assign(this.clipboard, response.body.clipboard)
    })
  },
  methods: {
    isInput () {
      return (document.activeElement.tagName === 'INPUT' ||
          document.activeElement.tagName === 'TEXTAREA')
    },
    KeyPress (e) {
      this.addKey(e)
      const evtobj = window.event ? event : e
      if (this.keys.includes(this.actionKey)) {
        if (this.keys.includes(67) && (this.keys.length == 3)) {
          const keys = this.keys.filter(key => { return (key > 48 && key < 54) })

          keys.forEach(item => {
            this.setClipboard((item - 48))
          })
        } else {
          if (evtobj.keyCode > 48 && evtobj.keyCode < 54) {
            this.pasteClipboard((evtobj.keyCode - 48))
          }
        }
      }
    },
    pasteClipboard (clipboardIndex) {
      if (this.isInput() && this.clipboard[clipboardIndex]) {
        const position = document.activeElement.selectionStart
        const text = document.activeElement.value
        document.activeElement.value = text.substr(0, position) + this.clipboard[clipboardIndex] + text.substr(position)
        document.activeElement.dispatchEvent(new CustomEvent('input'))
      }
    },
    saveClipboard () {
      UpdateClipboard(this.clipboard).then(response => {
        this.clipboard = response.body.clipboard
      })
    },
    setClipboard (index) {
      const textSelected = window.getSelection().toString()

      if (textSelected.length > 0) {
        console.log(textSelected)
        this.clipboard[index] = textSelected
        this.saveClipboard()
      }
    },
    addKey (e) {
      const evtobj = window.event ? event : e
      if (!this.keys.includes(evtobj.keyCode)) {
        this.keys.push(evtobj.keyCode)
      }
    },
    removeKey (e) {
      const evtobj = window.event ? event : e
      const position = this.keys.findIndex(key => { return evtobj.keyCode === key })

      if (position > -1) {
        this.keys.splice(position, 1)
      }
    }
  }
}
</script>
