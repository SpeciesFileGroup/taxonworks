import { EVENT_SMART_SELECTOR_UPDATE } from 'constants/index.js'

function smartSelectorRefresh (model) {
  const event = new CustomEvent(EVENT_SMART_SELECTOR_UPDATE, {
    detail: {
      model
    }
  })
  document.dispatchEvent(event)
}

export {
  smartSelectorRefresh
}
