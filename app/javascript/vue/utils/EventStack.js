export class EventStack {
  listenerStack = []

  constructor() {
    const handleProcessListeners = this.processListeners.bind(this)
    document.addEventListener('keydown', handleProcessListeners)
  }

  addListener(listener, options) {
    const listenerId =
      options.listenerId || Math.random().toString(36).substring(7)
    const index = this.listenerStack.findIndex(
      (listener) => listener.listenerId === listenerId
    )
    const atStart = !!options?.atStart
    const listenerObject = {
      listener,
      options,
      listenerId
    }

    if (index > -1) {
      this.listenerStack[index] = listenerObject
    } else if (atStart) {
      this.listenerStack.unshift(listenerObject)
    } else {
      this.listenerStack.push(listenerObject)
    }

    return listenerId
  }

  processListeners(e) {
    for (let i = 0; i < this.listenerStack.length; i++) {
      const { listener, options } = this.listenerStack[i]
      listener(e)

      if (options?.stopPropagation) {
        break
      }
    }
  }

  removeListener(id) {
    const index = this.listenerStack.findIndex(
      ({ listenerId }) => listenerId === id
    )

    if (index > -1) {
      this.listenerStack.splice(index, 1)
    }
  }

  removeAllListeners() {
    this.listenerStack = []
  }
}
