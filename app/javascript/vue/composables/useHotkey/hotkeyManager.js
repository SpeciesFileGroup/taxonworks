import { KEY_CODE } from './keycode.js'

const MODIFIERS = [
  { name: 'alt', key: 'alt', flag: 'altKey' },
  { name: 'ctrl', key: 'control', flag: 'ctrlKey' },
  { name: 'shift', key: 'shift', flag: 'shiftKey' },
  { name: 'meta', key: 'meta', flag: 'metaKey' }
]

class HotKeyManager {
  registeredHotkeys = {}
  pressedKeys = new Map()

  constructor() {
    if (typeof window !== 'undefined') {
      window.addEventListener('keydown', (e) => {
        const key = this.normalizeKey(e.key)
        const activeModifiers = this.getActiveModifiers(e)

        if (activeModifiers.length) this.pressedKeys.clear()

        this.removeReleasedModifiers(e)
        this.pressedKeys.set(e.code || key, key)

        const keys = new Set([...activeModifiers, ...this.pressedKeys.values()])
        const keyComb = this.getKeyComb([...keys])
        this.registeredHotkeys[keyComb]?.forEach((hotKey) => {
          if (!e.repeat || hotKey?.repeat) {
            if (hotKey.preventDefault) e.preventDefault()
            hotKey.handler([...hotKey.keys], e)
          }
        })
      })

      window.addEventListener('keyup', (e) => {
        this.pressedKeys.delete(e.code || this.normalizeKey(e.key))
        this.removeReleasedModifiers(e)
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

  getActiveModifiers = (e) =>
    MODIFIERS.filter(({ flag }) => e[flag]).map(({ name }) => name)

  removeReleasedModifiers = (e) => {
    const releasedKeys = MODIFIERS.filter(({ flag }) => !e[flag]).map(
      ({ key }) => key
    )

    this.pressedKeys.forEach((key, code) => {
      if (releasedKeys.includes(key)) this.pressedKeys.delete(code)
    })
  }

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
