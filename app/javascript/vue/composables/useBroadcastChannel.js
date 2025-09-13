import { computed, ref, shallowRef, toRaw, onBeforeUnmount } from 'vue'
import { useEventListener } from './useEventListener.js'

export function useBroadcastChannel(options = {}) {
  const {
    name,
    onMessage = () => {},
    onMessageError = () => {},
    onClose = () => {}
  } = options

  const isSupported = computed(() => !!window?.BroadcastChannel)
  const isClosed = shallowRef(false)

  const channel = ref()
  const data = ref()
  const error = shallowRef(null)

  const post = (data) => {
    if (channel.value) {
      channel.value.postMessage(toRaw(data))
    }
  }

  const close = () => {
    if (channel.value) {
      channel.value.close()
    }

    isClosed.value = true
  }

  if (isSupported.value) {
    const listenerOptions = {
      passive: true
    }

    channel.value = new BroadcastChannel(name)

    useEventListener(
      channel,
      'message',
      (e) => {
        onMessage(e)
        data.value = e.data
      },
      listenerOptions
    )

    useEventListener(
      channel,
      'messageerror',
      (e) => {
        onMessageError(e)
        error.value = e
      },
      listenerOptions
    )

    useEventListener(
      channel,
      'close',
      () => {
        onClose()
        isClosed.value = true
      },
      listenerOptions
    )
  }

  onBeforeUnmount(() => {
    close()
  })

  return {
    isSupported,
    channel,
    data,
    post,
    close,
    error,
    isClosed
  }
}
