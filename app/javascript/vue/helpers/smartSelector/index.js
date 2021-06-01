function SmartSelectorRefresh (model) {
  const event = new CustomEvent('smartselector:refresh', {
    detail: {
      model
    }
  })
  document.dispatchEvent(event)
}

export {
  SmartSelectorRefresh
}
