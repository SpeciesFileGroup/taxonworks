const PROGRESS_BAR_ID = 'rspack-progress-bar'
const PROGRESS_STATUS_BOX = 'rpsack-progress-status-box'

const RSPACK_WS_EVENT_PROGRESS_UPDATE = 'progress-update'
const RSPACK_WS_EVENT_UPDATE_COMPLETE = 'ok'
const RSPACK_WS_EVENT_CODE_CHANGE = 'invalid'

function makeProgressBar() {
  const element = document.createElement('div')

  element.setAttribute('id', PROGRESS_BAR_ID)
  Object.assign(element.style, {
    display: 'none',
    position: 'fixed',
    top: '0',
    left: '0',
    height: '4px',
    background: 'var(--color-update)',
    width: '0%',
    zIndex: '9999999',
    transition: 'width 0.2s'
  })

  document.body.appendChild(element)

  return element
}

function makeProgressStatusBox() {
  const element = document.createElement('div')

  element.setAttribute('id', PROGRESS_STATUS_BOX)
  Object.assign(element.style, {
    display: 'none',
    position: 'fixed',
    bottom: '10px',
    right: '10px',
    background: '#333333',
    color: 'white',
    font: '12px monospace',
    padding: '6px 12px',
    borderRadius: '4px',
    zIndex: '99999',
    pointerEvents: 'none',
    transition: 'all 0.2s',
    boxShadow: 'var(--panel-shadow)'
  })

  document.body.appendChild(element)

  return element
}

function loadProgressBar() {
  const socketUrl = __RSPACK_WS_URL__
  const progressBar =
    document.querySelector(PROGRESS_BAR_ID) || makeProgressBar()
  const box =
    document.querySelector(PROGRESS_STATUS_BOX) || makeProgressStatusBox()

  const ws = new WebSocket(socketUrl)

  const handlers = {
    [RSPACK_WS_EVENT_PROGRESS_UPDATE]: ({ percent, msg }) => {
      const pct = Math.round(percent)
      box.textContent = `${pct}% ${msg}`
      progressBar.style.width = pct + '%'
    },

    [RSPACK_WS_EVENT_UPDATE_COMPLETE]: () => {
      box.textContent = 'Compilation complete'
      progressBar.style.width = '100%'
      progressBar.style.display = 'none'
      box.style.display = 'none'
    },

    [RSPACK_WS_EVENT_CODE_CHANGE]: () => {
      box.style.display = 'block'
      box.textContent = 'Recompiling...'
      progressBar.style.width = '0%'
      progressBar.style.display = 'block'
    }
  }

  ws.onmessage = (event) => {
    try {
      const data = JSON.parse(event.data)
      const handler = handlers[data.type]

      if (handler) {
        handler(data.data || {})
      }
    } catch {
      console.log(e)
    }
  }

  ws.onclose = () => {
    box.textContent = 'Disconnected from the dev server'
  }

  document.addEventListener('turbolinks:before-render', () => {
    ws.close()
  })
}

document.addEventListener('turbolinks:load', () => {
  loadProgressBar()
})

loadProgressBar()
