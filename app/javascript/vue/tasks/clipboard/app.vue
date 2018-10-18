<template>
  <div id="vue-clipboard-app">
    <ul class="slide-panel-category-content">
      <li
        v-for="(clip, index) in clipboard"
        class="slide-panel-category-item">
        <div>
          <p>Shortcut: <b>Ctrl + {{ index }}</b></p>
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

  import Spinner from '../../components/spinner.vue'
  import { GetClipboard, UpdateClipboard } from './request/resources'

  export default {
    components: {
      Spinner
    },
    computed: {
      isInput() {
        return (document.activeElement.tagName == 'INPUT' || 
            document.activeElement.tagName == 'TEXTAREA')
      },
      actionKey() {
        return (navigator.platform.indexOf('Mac') > -1 ? 17 : 18)
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
          17: 'Alt',
          18: 'Ctrl'
        },
        keys: []
      }
    },
    mounted() {
      $(document).off("keydown");
      $(document).on("keyup")
      $(document).on("keydown", this.KeyPress);
      $(document).on("keyup", this.removeKey)
      GetClipboard().then(response => {
        Object.assign(this.clipboard, response.clipboard)
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
          }
        }
      },
      saveClipboard() {
        UpdateClipboard(this.clipboard).then(response => {
          this.clipboard = response.clipboard
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
