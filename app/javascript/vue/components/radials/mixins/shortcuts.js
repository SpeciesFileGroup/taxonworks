import { RadialEventStack } from '@/utils'
import { isMac } from '@/helpers/os'

export default {
  computed: {
    shortcutList() {
      const sliceTitles = Object.keys(this.metadata?.endpoints || {})
      const shortcuts = Object.fromEntries(
        sliceTitles.map((title) => {
          const key = title[0]
          const titles = sliceTitles.filter((item) => item[0] === key)

          return [key, titles]
        })
      )

      return shortcuts
    }
  },

  data() {
    return {
      listenerId: undefined
    }
  },

  created() {
    document.addEventListener('turbolinks:load', () => {
      RadialEventStack.removeAllListeners()
    })
  },

  methods: {
    setShortcutsEvent() {
      this.listenerId = RadialEventStack.addListener(this.shortcutsListener, {
        atStart: true,
        stopPropagation: true
      })
    },

    removeListener() {
      RadialEventStack.removeListener(this.listenerId)
    },

    shortcutsListener(e) {
      const key = e.key.toLowerCase()
      const titles = this.shortcutList[key]
      const activeElement = document.activeElement.tagName

      if ((isMac() && !e.ctrlKey) || (!isMac() && !e.altKey)) {
        return
      }

      if (activeElement === 'INPUT' || activeElement === 'TEXTAREA') {
        return
      }

      if (titles) {
        const index = titles.includes(this.currentAnnotator)
          ? titles.findIndex((title) => title === this.currentAnnotator) + 1
          : 0

        if (titles.length > index) {
          this.currentAnnotator = titles[index]
        } else {
          this.currentAnnotator = titles[0]
        }

        e.preventDefault()
        e.stopImmediatePropagation()
      }
    }
  }
}
