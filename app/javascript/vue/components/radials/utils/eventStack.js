let listenerStack = []

const addListener = (listener, options) => {
  const listenerId = options.listenerId || Math.random().toString(36).substring(7)
  const index = listenerStack.findIndex(listener => listener.listenerId === listenerId)
  const atStart = !!options?.atStart
  const listenerObject = {
    listener,
    options,
    listenerId
  }

  if (index > -1) {
    listenerStack[index] = listenerObject
  } else if (atStart) {
    listenerStack.unshift(listenerObject)
  } else {
    listenerStack.push(listenerObject)
  }

  return listenerId
}

const processListeners = e => {
  for (let i = 0; i < listenerStack.length; i++) {
    const { listener, options } = listenerStack[i]
    listener(e)

    if (options?.stopPropagation) {
      break
    }
  }
}

const removeListener = (id) => {
  const index = listenerStack.findIndex(({ listenerId }) => listenerId === id)

  if (index > -1) {
    listenerStack.splice(index, 1)
  }
}

const removeAllListeners = () => {
  listenerStack = []
}

document.addEventListener('keydown', processListeners)

export default {
  addListener,
  removeListener,
  removeAllListeners
}
