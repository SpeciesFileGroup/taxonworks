import { KEY_CODE } from './keycode.js'

class HotKeyManager {
  registeredHotkeys = {}
  pressedKeys = new Map()

  constructor() {
    if (typeof window !== 'undefined') {
      window.addEventListener('keydown', (e) => {
        const key = this.normalizeKey(e.key)

        if (e.altKey || e.ctrlKey || e.shiftKey || e.metaKey) {
          this.pressedKeys.clear()
          if (e.altKey) this.pressedKeys.set('alt', false)
          if (e.ctrlKey) this.pressedKeys.set('control', false)
          if (e.shiftKey) this.pressedKeys.set('shift', false)
          if (e.metaKey) this.pressedKeys.set('meta', false)
        }

        this.pressedKeys.set(key, e.repeat)

        const keyComb = this.getKeyComb(Array.from(this.pressedKeys.keys()))
        this.registeredHotkeys[keyComb]?.forEach((hotKey) => {
          if (!e.repeat || hotKey?.repeat) {
            if (hotKey.preventDefault) e.preventDefault()
            hotKey.handler([...hotKey.keys], e)
          }
        })
      })

      window.addEventListener('keyup', (e) => {
        const key = this.normalizeKey(e.key)

        if (this.pressedKeys.has(key)) this.pressedKeys.delete(key)
      })

      window.addEventListener('blur', () => {
        this.pressedKeys.clear()
      })

      window.addEventListener('focus', () => {
        this.pressedKeys.clear()
      })
    }
  }

  normalizeKey = (key) => String(key).toLowerCase()

  registerHotKey = (hotkey) => {
    const keyComb = this.getKeyComb([...hotkey.keys])

    if (!this.registeredHotkeys[keyComb]) this.registeredHotkeys[keyComb] = []

    this.registeredHotkeys[keyComb].push(hotkey)
  }

  getKeyComb = (keys) => {
    const normalizedKeys = keys.map(this.normalizeKey)
    const convertKeys = normalizedKeys.map((key) => KEY_CODE[key] || key)

    return convertKeys.sort().join(' ')
  }

  removeHotKey = (hotKey) => {
    const keyComb = this.getKeyComb([...hotKey.keys])
    const index = this.registeredHotkeys[keyComb]?.indexOf(hotKey) ?? -1

    if (index !== -1) {
      this.registeredHotkeys[keyComb].splice(index, 1)
      return true
    }

    return false
  }
}

export default new HotKeyManager()
