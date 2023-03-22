<template>
  <div
    id="vue-clipboard-app"
    class="full_width"
  >
    <ul class="slide-panel-category-content">
      <li
        v-for="(_, index) in clipboard"
        :key="index"
        class="slide-panel-category-item"
      >
        <div class="full_width padding-large-right capitalize">
          <p>Shortcut: <b>{{ actionKey }} + {{ keyPaste }} + {{ index }}</b></p>
          <div class="middle">
            <textarea
              class="full_width"
              rows="5"
              v-model="clipboard[index]"
              @blur="saveClipboard"
            />
          </div>
        </div>
      </li>
    </ul>
    <p class="slide-panel-category-content">
      Use <b class="capitalize">{{ actionKey }} + {{ keyCopy }} + Number</b> to copy a text to the clipboard box
    </p>
  </div>
</template>
<script setup>
import { ref, onBeforeMount, onBeforeUnmount } from 'vue'
import { ProjectMember } from 'routes/endpoints'
import platformKey from 'helpers/getPlatformKey'
import useHotkey from 'vue3-hotkey'

const clipboard = ref({
  1: '',
  2: '',
  3: '',
  4: '',
  5: ''
})

const actionKey = platformKey()
const keyCopy = 'c'
const keyPaste = 'v'

function generateShortcuts () {
  const hotkeys = []

  Object.keys(clipboard.value).forEach(slot => {
    hotkeys.push({
      keys: [actionKey, keyPaste, slot],
      preventDefault: true,
      handler () {
        pasteClipboard(slot)
      }
    })

    hotkeys.push({
      keys: [actionKey, keyCopy, slot],
      preventDefault: true,
      handler () {
        setClipboard(slot)
      }
    })
  })

  return hotkeys
}

const hotkeys = ref(generateShortcuts())

TW.workbench.keyboard.createLegend(`${platformKey()}+f`, 'Search', 'Filter sources')
TW.workbench.keyboard.createLegend(`${platformKey()}+r`, 'Reset task', 'Filter sources')

const stop = useHotkey(hotkeys.value)

onBeforeMount(() => {
  ProjectMember.clipboard().then(response => {
    Object.assign(clipboard.value, response.body.clipboard)
  })
})

onBeforeUnmount(() => {
  stop.forEach(hotkey => hotkey())
})

function isInput () {
  return document.activeElement.tagName === 'INPUT' ||
      document.activeElement.tagName === 'TEXTAREA'
}

function pasteClipboard (clipboardIndex) {
  if (isInput() && clipboard.value[clipboardIndex]) {
    const position = document.activeElement.selectionStart
    const text = document.activeElement.value

    document.activeElement.value = text.substr(0, position) + clipboard.value[clipboardIndex] + text.substr(position)
    document.activeElement.dispatchEvent(new CustomEvent('input'))
  }
}

function saveClipboard () {
  ProjectMember.updateClipboard(clipboard.value).then(response => {
    clipboard.value = response.body.clipboard
  })
}

function setClipboard (index) {
  const textSelected = isInput()
    ? document.activeElement.value
    : window.getSelection().toString()

  if (textSelected.length > 0) {
    clipboard.value[index] = textSelected
    saveClipboard()
  }
}

</script>

<script>
export default {
  name: 'ClipboardApp'
}
</script>
