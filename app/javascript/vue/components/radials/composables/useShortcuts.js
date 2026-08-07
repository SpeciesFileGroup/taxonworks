import { RadialEventStack } from '@/utils'
import { isMac } from '@/helpers/os'
import { computed, onBeforeMount } from 'vue'

export function useShortcuts({ metadata, currentAnnotator }) {
  const shortcutList = computed(() => {
    const sliceTitles = Object.keys(metadata.value?.endpoints || {})
    const shortcuts = Object.fromEntries(
      sliceTitles.map((title) => {
        const key = title[0]
        const titles = sliceTitles.filter((item) => item[0] === key)

        return [key, titles]
      })
    )

    return shortcuts
  })

  let listenerId

  onBeforeMount(() => {
    document.addEventListener(
      'turbolinks:load',
      RadialEventStack.removeAllListeners
    )
  })

  function setShortcutsEvent() {
    listenerId = RadialEventStack.addListener(shortcutsListener, {
      atStart: true,
      stopPropagation: true
    })
  }

  function removeListener() {
    RadialEventStack.removeListener(listenerId)
  }

  function shortcutsListener(e) {
    const key = e.key.toLowerCase()
    const titles = shortcutList.value[key]
    const activeElement = document.activeElement.tagName

    if ((isMac() && !e.ctrlKey) || (!isMac() && !e.altKey)) {
      return
    }

    if (activeElement === 'INPUT' || activeElement === 'TEXTAREA') {
      return
    }

    if (titles) {
      const index = titles.includes(currentAnnotator.value)
        ? titles.findIndex((title) => title === currentAnnotator.value) + 1
        : 0

      currentAnnotator.value = titles.length > index ? titles[index] : titles[0]

      e.preventDefault()
      e.stopImmediatePropagation()
    }
  }

  return {
    setShortcutsEvent,
    removeListener
  }
}
