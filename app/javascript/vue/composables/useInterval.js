import { onBeforeUnmount } from 'vue'

export function useInterval(fn, time) {
  let interval = setInterval(fn, time)

  function resume() {
    interval = setInterval(fn, time)
  }

  function stop() {
    clearInterval(interval)
  }

  onBeforeUnmount(stop)

  return {
    resume,
    stop
  }
}
