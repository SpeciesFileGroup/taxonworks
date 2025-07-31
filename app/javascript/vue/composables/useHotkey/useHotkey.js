import { onUnmounted } from 'vue'
import manager from './hotkeyManager.js'

export function useHotkey(hotKeys) {
  hotKeys.forEach((hotkey) => manager.registerHotKey(hotkey))

  onUnmounted(() => {
    hotKeys.forEach((hk) => manager.removeHotKey(hk))
  })

  return hotKeys.map((hk) => (customHk) => {
    const deleteHk = customHk ?? hk

    manager.removeHotKey(deleteHk)
  })
}
