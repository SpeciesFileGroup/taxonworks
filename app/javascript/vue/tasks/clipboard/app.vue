<template>
  <div id="vue-clipboard-app">
    <ul class="slide-panel-category-content">
      <li
        v-for="(clip, index) in clipboard"
        class="slide-panel-category-item">
        <div>
          <p>Shortcut: <b>{{ keyCode[actionKey] }} {{ isLinux ? '+ Shift' : '' }} + {{ index }}</b></p>
          <div class="middle">
            <textarea
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
      isInput() {
        return (document.activeElement.tagName == 'INPUT' || 
            document.activeElement.tagName == 'TEXTAREA')
      },
      actionKey() {
        return (navigator.platform.indexOf('Mac') > -1 ? 17 : 18)
      },
      isLinux () {
        return window.navigator.userAgent.indexOf("Linux") > -1
      }
    },
    data() {
      return {
        clipboard: {
          1: '',
          2: '',
          3: '',
          4: '',
          5: '',
        },
        keyCode: {
          17: 'Ctrl',
          18: 'Alt'
        },
        keys: []
      }
    },
    mounted() {
      document.addEventListener('turbolinks:load', (event) => {
        document.removeEventListener("keydown", this.KeyPress)
        document.removeEventListener("keyup", this.removeKey)
      })
      document.addEventListener("keydown", this.KeyPress)
      document.addEventListener("keyup", this.removeKey)
      GetClipboard().then(response => {
        console.log(response)
        Object.assign(this.clipboard, response.body.clipboard)
      })
    },
    methods: {
      KeyPress(e) {
        this.addKey(e)
        let evtobj = window.event? event : e
        if(this.keys.includes(this.actionKey)) {
          if(this.keys.includes(67) && (this.keys.length == 3)) {
            let keys = this.keys.filter(key => { return (key > 48 && key < 54) })
            let that = this
            keys.forEach(item => {
              that.setClipboard((item - 48))
            })
          }
          else {
            if(evtobj.keyCode > 48 && evtobj.keyCode < 54) {
              this.pasteClipboard((evtobj.keyCode - 48))
            }
          }
        }
      },
      pasteClipboard(clipboardIndex) {
        if(this.clipboard[clipboardIndex]) {
          if(this.isInput) {
            let position = document.activeElement.selectionStart
            let text = document.activeElement.value
            document.activeElement.value = text.substr(0, position) + this.clipboard[clipboardIndex] + text.substr(position)
            document.activeElement.dispatchEvent(new CustomEvent("input"))
          }
        }
      },
      saveClipboard() {
        UpdateClipboard(this.clipboard).then(response => {
          this.clipboard = response.body.clipboard
        })        
      },
      setClipboard(index) {
        if(this.isInput && (document.activeElement.value.length > 0)) {
          this.clipboard[index] = document.activeElement.value
          this.saveClipboard()
        }
      },
      addKey(e) {
        let evtobj = window.event? event : e
        if(!this.keys.includes(evtobj.keyCode)) {
          this.keys.push(evtobj.keyCode)
        }
      },
      removeKey(e) {
        let evtobj = window.event? event : e
        let position = this.keys.findIndex(key => { return evtobj.keyCode == key} )
        if(position > -1) {
          this.keys.splice(position, 1)
        }
      }
    }
  }
</script>
<style scoped>
  input, textarea {
    width: 340px;
    height: 50px;
  }
</style>
