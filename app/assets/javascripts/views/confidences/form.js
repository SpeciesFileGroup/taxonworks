/*
  Handles the selection and removal of confidence levels on confidences/new. 
  !! Form works per referenced object with nested attributes, not on a Confidence instance.
  Could ulitmately be simplified to reference global_ids in various places.

*/
var TW = TW || {}
TW.views = TW.views || {}
TW.views.confidences = TW.views.confidences || {}
TW.views.confidences.form = TW.views.confidences.form || {}

Object.assign(TW.views.confidences.form, {
  initialize: function () {
    document.querySelectorAll('.confidence_level_form').forEach((form) => {
      TW.views.confidences.form.initialize_form(form)
    })
  },

  initialize_form: function (form) {
    this.initialize_confidence_level_picker(form)
    this.bind_remove_links(form.querySelectorAll('.remove_confidence'))
  },

  clear_confidence_level_picker: function (form) {
    const input = form.querySelector('.confidence_level_picker_autocomplete')
    if (input) input.value = ''
  },

  initialize_confidence_level_picker: function (form) {
    const input = form.querySelector('.confidence_level_picker_autocomplete')
    if (!input) return

    const ac = new TWAutocomplete(input, {
      source: function (term, respond) {
        fetch('/confidence_levels/lookup?term=' + encodeURIComponent(term))
          .then((r) => r.json())
          .then((data) => respond(data))
          .catch(() => respond([]))
      },
      minLength: 1,
      open: function () {
        TW.views.confidences.form.bind_hover(form)
      },
      select: function (ui) {
        TW.views.confidences.form.insert_confidence(
          form,
          ui.item.object_id,
          ui.item.label
        )
        TW.views.confidences.form.clear_confidence_level_picker(form)
        return false
      }
    })

    const originalRenderMenu = ac._renderMenu.bind(ac)
    ac._renderMenu = function () {
      this._menu.innerHTML = ''

      this._items.forEach((item, idx) => {
        const li = document.createElement('li')
        li.className = 'confidence'
        li.dataset.index = idx
        li.setAttribute('role', 'option')

        li.innerHTML =
          `<a>${item.label} ` +
          `<span class="hoverme" ` +
          `data-confidence-level-definition="${item.definition}" ` +
          `data-confidence-level-id="${item.object_id}">...</span>` +
          `</a>`

        this._menu.appendChild(li)
      })

      originalRenderMenu()
    }
  },

  // hover sobre los tres puntitos
  bind_hover: function () {
    document.querySelectorAll('.hoverme').forEach((span) => {
      span.addEventListener('mouseenter', function () {
        const def = this.dataset.confidenceLevelDefinition
        this.innerHTML = `... ${def}`
      })
      span.addEventListener('mouseleave', function () {
        this.textContent = '...'
      })
    })
  },

  insert_confidence: function (form, confidence_level_id, label) {
    const random_index = new Date().getTime()
    const base_class =
      'confidence_object[confidences_attributes][' + random_index + ']'
    const confidence_list = form.querySelector('.confidence_list')

    if (!confidence_list) return

    confidence_list.insertAdjacentHTML(
      'beforeend',
      `<input hidden name="${base_class}[confidence_level_id]" value="${confidence_level_id}">`
    )

    const li = document.createElement('li')
    li.className = 'confidence_item'
    li.dataset.confidenceIndex = random_index
    li.innerHTML = `${label}&nbsp;`
    li.appendChild(TW.views.confidences.form.remove_link())
    confidence_list.appendChild(li)
  },

  remove_link: function () {
    const link = document.createElement('a')
    link.href = '#'
    link.dataset.turbolinks = 'false'
    link.className = 'remove_confidence_level'
    link.textContent = 'remove'

    TW.views.confidences.form.bind_remove_links([link])
    return link
  },

  bind_remove_links: function (links) {
    links.forEach((link) => {
      link.addEventListener('click', function (e) {
        e.preventDefault()
        const list_item = this.closest('li')
        if (!list_item) return

        const form = list_item.closest('.confidence_picker')
        const confidence_id = list_item.dataset.confidenceId
        const confidence_index = list_item.dataset.confidenceIndex
        const base_class = 'confidence_object[confidences_attributes]'

        if (confidence_id !== undefined) {
          const confidence_list = list_item.closest('.confidence_list')
          if (confidence_list) {
            confidence_list.insertAdjacentHTML(
              'beforeend',
              `<input hidden name="${base_class}[${confidence_index}][id]" value="${confidence_id}">`
            )
            confidence_list.insertAdjacentHTML(
              'beforeend',
              `<input hidden name="${base_class}[${confidence_index}][_destroy]" value="1">`
            )

            const alert = confidence_list.parentElement.querySelector(
              '.confidence_level_picker_alert'
            )
            if (alert) {
              TW.views.confidences.form.warn_for_save(alert)
            }
          }
        }

        list_item.remove()
      })
    })
  },

  warn_for_save: function (msg_div) {
    msg_div.style.display = 'block'
    msg_div.classList.add('warning')
    msg_div.innerHTML =
      'Update confidences click required to confirm removal/reorder of confidence level.'
  }
})

document.addEventListener('turbolinks:load', () => {
  TW.views.confidences.form.initialize()
})
