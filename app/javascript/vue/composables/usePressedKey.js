import { onBeforeMount, onBeforeUnmount, ref } from 'vue'

export function usePressedKey() {
  const pressedKeys = ref(new Set())

  const addKey = (e) => {
    pressedKeys.value.add(e.key)
  }

  const removeKey = (e) => {
    pressedKeys.value.remove(e.key)
  }

  const isKeyPressed = (key) => {
    pressedKeys.value.has(key)
  }

  onBeforeMount(() => {
    window.addEventListener('keydown', addKey)
    window.addEventListener('keyup', removeKey)
  })
  onBeforeUnmount(() => {
    window.addEventListener('keydown', addKey)
    window.addEventListener('keyup', removeKey)
  })

  return {
    isKeyPressed,
    pressedKeys
  }
}
