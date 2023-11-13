import { reactive, computed, watch, onBeforeUnmount } from 'vue'

export function useDraggable({ target, handler }) {
  const position = reactive({
    init: false,
    x: 0,
    y: 0,
    width: 0,
    height: 0,
    isDragging: false,
    dragStartX: null,
    dragStartY: null
  })

  const style = computed(() => {
    if (position.init) {
      return {
        position: 'absolute',
        left: position.x + 'px',
        top: position.y + 'px',
        width: position.width + 'px',
        height: position.height + 'px',
        'box-shadow': position.isDragging
          ? '3px 6px 16px rgba(0, 0, 0, 0.15)'
          : '',
        transform: position.isDragging ? 'translate(-3px, -6px)' : '',
        cursor: position.isDragging ? 'grab' : 'pointer'
      }
    }
    return {}
  })

  const styleHandler = computed(() => {
    if (position.init) {
      return {
        cursor: position.isDragging ? 'grab' : 'pointer'
      }
    }
    return {}
  })

  const onMouseDown = (e) => {
    const { clientX, clientY } = e

    position.dragStartX = clientX - position.x
    position.dragStartY = clientY - position.y

    position.isDragging = true

    document.addEventListener('mouseup', onMouseUp)
    document.addEventListener('mousemove', onMouseMove)
  }

  const onMouseMove = (e) => {
    const { clientX, clientY } = e

    position.x = clientX - position.dragStartX
    position.y = clientY - position.dragStartY
  }

  const onMouseUp = (e) => {
    position.isDragging = false
    position.dragStartX = null
    position.dragStartY = null
    document.removeEventListener('mouseup', onMouseUp)
    document.removeEventListener('mousemove', onMouseMove)
  }

  watch(target, (element) => {
    if (!element instanceof HTMLElement) return
    const rect = element.getBoundingClientRect(element)

    position.init = true
    position.x = Math.round(rect.x)
    position.y = Math.round(rect.y)
    position.width = Math.round(rect.width)
    position.height = Math.round(rect.height)
  })

  watch(handler, (handler) => {
    if (handler instanceof HTMLElement) {
      handler.addEventListener('mousedown', onMouseDown)
    }
  })

  onBeforeUnmount(() => {
    document.removeEventListener('mouseup', onMouseUp)
    document.removeEventListener('mousemove', onMouseMove)
  })

  return {
    position,
    style,
    styleHandler
  }
}
