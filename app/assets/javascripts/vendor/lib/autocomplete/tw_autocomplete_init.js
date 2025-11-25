function tw_autocomplete_init(inputEl, options = {}) {
  if (!inputEl) return

  const form = inputEl.closest('form')
  const url = inputEl.dataset.twAutocompleteUrl
  const method = inputEl.dataset.twMethod
  const defaultResponseValues = {}
  defaultResponseValues[method] = ''

  const emptyResult = () => [{
    id: '',
    value: '',
    label: '-- None --',
    label_html: '-- None --',
    response_values: defaultResponseValues
  }]

  const ac = new TWAutocomplete(inputEl, {
    source(term, respond) {
      if (!term || term.trim() === '') {
        respond(emptyResult())
        return
      }

      const separator = url.includes('?') ? '&' : '?'
      const fullUrl = url + separator + 'term=' + encodeURIComponent(term)

      fetch(fullUrl)
        .then((r) => r.json())
        .then((data) => {
          let items = (data || []).map((it) => ({
            id: it.id,
            value: it.value || it.label,
            label: it.label,
            label_html: it.label_html || it.label,
            response_values: it.response_values
          }))

          respond(items.length === 0 ? emptyResult() : items)
        })
        .catch(() => respond([]))
    },
    minLength: 1,
    appendTo: inputEl.parentElement,
    open() {
      inputEl.classList.remove('ui-autocomplete-loading')
    },
    select(ui) {
      const selected = ui.item
      const responseValues = selected.response_values
      if (responseValues) {
        Object.entries(responseValues).forEach(([key, value]) => {
          form
            .querySelectorAll(`input[name="${key}"]`)
            .forEach((el) => el.remove())

          const hidden = document.createElement('input')

          hidden.type = 'hidden'
          hidden.name = key
          hidden.value = value
          form.appendChild(hidden)
        })
      }
      if (inputEl.dataset.sendSelect === 'true') {
        form.submit()
      }
    }
  })

  const originalRenderMenu = ac._renderMenu.bind(ac)

  ac._renderMenu = function () {
    this._menu.innerHTML = ''
    const term = this.input.value

    this._items.forEach((item, idx) => {
      const el = document.createElement('li')
      el.className = 'autocomplete-item'
      el.setAttribute('data-index', idx)
      el.setAttribute('data-model-id', item.id)
      el.innerHTML = this._highlightLabel(item.label, term)
      this._menu.appendChild(el)
    })

    originalRenderMenu()
  }

  return ac
}

document.addEventListener('turbolinks:load', () => {
  const autocompletes = document.querySelectorAll('[data-tw-autocomplete-url]')

  autocompletes.forEach((el) => {
    tw_autocomplete_init(el)
  })
})
