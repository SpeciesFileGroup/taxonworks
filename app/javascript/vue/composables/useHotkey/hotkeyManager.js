import { KEY_CODE } from './keycode.js'

class HotKeyManager {
  registeredHotkeys = {}
  pressedKeys = new Map()

  constructor() {
    if (typeof window !== 'undefined') {
      window.addEventListener('keydown', (e) => {
        this.pressedKeys.set(e.key, e.repeat)
        const keyComb = this.getKeyComb(Array.from(this.pressedKeys.keys()))
        this.registeredHotkeys[keyComb]?.forEach((hotKey) => {
          if (!e.repeat || hotKey?.repeat) {
            if (hotKey.preventDefault) e.preventDefault()
            hotKey.handler([...hotKey.keys], e)
          }
        })
      })
      window.addEventListener('keyup', (e) => {
        if (this.pressedKeys.has(e.key)) this.pressedKeys.delete(e.key)
      })
      window.addEventListener('blur', () => {
        this.pressedKeys.clear()
      })
    }
  }

  registerHotKey = (hotkey) => {
    const keyComb = this.getKeyComb([...hotkey.keys])
    if (!this.registeredHotkeys[keyComb]) this.registeredHotkeys[keyComb] = []

    this.registeredHotkeys[keyComb].push(hotkey)
  }

  getKeyComb = (keys) => {
    const convertKeys = keys.map((item) => {
      const stringKey = KEY_CODE[item]
      if (stringKey) return stringKey

      return item
    })
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
