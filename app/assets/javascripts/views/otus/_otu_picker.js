/*
 Used to select, or create a new OTU, inline.
 */
const OTU_PICKER_WIDGET = {
  current_otu_id: null,
  current_otu_label: null,
  object_name: null,

  initialize_otu_picker: function (form) {
    OTU_PICKER_WIDGET.object_name = form.dataset.objectName
    OTU_PICKER_WIDGET.initialize_autocomplete(form)
    OTU_PICKER_WIDGET.bind_new_otu_link(form)
    OTU_PICKER_WIDGET.bind_add_ok(form)
    OTU_PICKER_WIDGET.bind_undo_new_otu(form)
    OTU_PICKER_WIDGET.cache_existing_otu(form)
  },

  initialize_autocomplete: function (form) {
    const input = form.querySelector('.otu_picker_autocomplete')
    if (!input) return

    const ac = new TWAutocomplete(input, {
      source: function (term, respond) {
        fetch('/otus/autocomplete?term=' + encodeURIComponent(term))
          .then((r) => r.json())
          .then((data) => {
            respond(data)

            if (data.length === 0) {
              const addNew = document.querySelector('#otu_picker_add_new')
              if (addNew) addNew.style.display = 'block'

              const nameField = document.querySelector('#XXX_otu_name_field')
              const acInput = document.querySelector(
                '#XXX_otu_picker_autocomplete'
              )
              if (nameField && acInput) {
                nameField.value = acInput.value
              }
            }
          })
          .catch(() => respond([]))
      },
      minLength: 1,
      select: function (ui) {
        OTU_PICKER_WIDGET.select_otu(form, ui.item.id)
        input.value = ui.item.label
        return false
      }
    })

    // custom render
    const originalRenderMenu = ac._renderMenu.bind(ac)
    ac._renderMenu = function () {
      this._menu.innerHTML = ''

      this._items.forEach((item, idx) => {
        const li = document.createElement('li')
        li.className = 'autocomplete'
        li.id = `ui-otu-id-${item.id}`
        li.dataset.index = idx
        li.setAttribute('role', 'option')
        li.innerHTML = `<a>${item.label}</a>`
        this._menu.appendChild(li)
      })

      originalRenderMenu()
    }
  },

  select_otu: function (form, otu_id) {
    const selected = document.querySelector('#selected_otu_id')
    if (selected) selected.value = otu_id
    OTU_PICKER_WIDGET.cache_existing_otu(form)
  },

  bind_new_otu_link: function (form) {
    const btn = form.querySelector('#otu_picker_add_new')
    if (!btn) return

    btn.addEventListener('click', () => {
      const newOtu = document.querySelector('#new_otu')
      if (newOtu) newOtu.style.display = 'block'

      btn.style.display = 'none'

      const acInput = document.querySelector('#XXX_otu_picker_autocomplete')
      if (acInput) acInput.hidden = true
    })
  },

  bind_add_ok: function (form) {
    const btn = form.querySelector('#otu_picker_add_ok')
    if (!btn) return

    btn.addEventListener('click', () => {
      OTU_PICKER_WIDGET.show_original_search(form)

      const acInput = document.querySelector('#XXX_otu_picker_autocomplete')
      if (acInput) {
        acInput.value = OTU_PICKER_WIDGET.get_autocomplete_name(form)
      }

      const selected = document.querySelector('#selected_otu_id')
      if (selected) selected.value = ''
    })
  },

  bind_undo_new_otu: function (form) {
    const btn = form.querySelector('#otu_picker_new_undo')
    if (!btn) return

    btn.addEventListener('click', () => {
      const nameField = document.querySelector('#XXX_otu_name_field')
      if (nameField) nameField.value = ''

      const taxonField = document.querySelector(
        '#taxon_name_id_for_inline_otu_picker'
      )
      if (taxonField) taxonField.value = ''

      const hiddenInput = document.querySelector(
        `input[name='${OTU_PICKER_WIDGET.object_name}[otu_attributes][taxon_name_id]']`
      )
      if (hiddenInput) hiddenInput.remove()

      OTU_PICKER_WIDGET.show_original_search(form)

      const acInput = document.querySelector('#XXX_otu_picker_autocomplete')
      if (acInput) {
        acInput.value = OTU_PICKER_WIDGET.current_otu_label
      }

      OTU_PICKER_WIDGET.select_otu(form, OTU_PICKER_WIDGET.current_otu_id)
    })
  },

  show_original_search: function (form) {
    const newOtu = form.querySelector('#new_otu')
    if (newOtu) newOtu.style.display = 'none'

    const acInput = form.querySelector('#XXX_otu_picker_autocomplete')
    if (acInput) acInput.hidden = false
  },

  cache_existing_otu: function (form) {
    const selected = form.querySelector('#selected_otu_id')
    const acInput = form.querySelector('#XXX_otu_picker_autocomplete')

    OTU_PICKER_WIDGET.current_otu_id = selected ? selected.value : null
    OTU_PICKER_WIDGET.current_otu_label = acInput ? acInput.value : null
  },

  get_autocomplete_name: function (form) {
    const nameField = form.querySelector('#XXX_otu_name_field')
    const taxonField = form.querySelector(
      '#taxon_name_id_for_inline_otu_picker'
    )

    return (
      (nameField ? nameField.value : '') +
      ' [' +
      (taxonField ? taxonField.value : '') +
      '] (a new OTU)'
    )
  }
}

document.addEventListener('turbolinks:load', () => {
  document.querySelectorAll('.otu_picker').forEach((form) => {
    OTU_PICKER_WIDGET.initialize_otu_picker(form)
  })
})
