var TW = TW || {}
TW.views = TW.views || {}
TW.views.people = TW.views.people || {}
TW.views.people.role_picker = TW.views.people.role_picker || {}

Object.assign(TW.views.people.role_picker, {
  initialize_role_picker: function (form, role_type) {
    this.initialize_autocomplete(form)
    this.bind_new_link(form)
    this.bind_switch_link(form)
    this.bind_expand_link(form)
    this.bind_label_mirroring(form)
    this.bind_remove_links(form.querySelectorAll('.remove_role'))
    this.make_role_list_sortable(form)
    this.bind_position_handling_to_submit_button(form)
  },

  get_first_name: function (string) {
    if (string.indexOf(',') > 1 || string.indexOf(' ') > 1) {
      let delimiter = ','
      if (string.indexOf(', ') > 1) delimiter = ', '
      if (string.indexOf(' ') > 1 && delimiter !== ', ') delimiter = ' '
      return string.split(delimiter, 2)[0]
    }
    return null
  },

  get_last_name: function (string) {
    if (string.indexOf(',') > 1 || string.indexOf(' ') > 1) {
      let delimiter = ','
      if (string.indexOf(', ') > 1) delimiter = ', '
      if (string.indexOf(' ') > 1 && delimiter !== ', ') delimiter = ' '
      return string.split(delimiter, 2)[1]
    }
    return string
  },

  get_full_name: function (first_name, last_name) {
    let separator = first_name && last_name ? ', ' : ''
    return (last_name || '') + separator + (first_name || '')
  },

  clear_role_picker: function (form) {
    const role_picker = form.querySelector('.role_picker_autocomplete')
    if (role_picker) role_picker.value = ''
    const newPerson = form.querySelector('.new_person')
    if (newPerson) newPerson.setAttribute('hidden', 'true')
  },

  initialize_autocomplete: function (form) {
    const input = form.querySelector('.role_picker_autocomplete')
    if (!input) return

    const ac = new TWAutocomplete(input, {
      source: function (term, respond) {
        fetch('/people/autocomplete?term=' + encodeURIComponent(term))
          .then((r) => r.json())
          .then((data) => respond(data))
          .catch(() => respond([]))
      },
      minLength: 1,
      open: function () {
        TW.views.people.role_picker.bind_hover(form)
      },
      select: function (ui) {
        TW.views.people.role_picker.insert_existing_person(
          form,
          ui.item.object_id,
          ui.item.label
        )
        TW.views.people.role_picker.clear_role_picker(form)
        return false
      }
    })

    const originalRenderMenu = ac._renderMenu.bind(ac)
    ac._renderMenu = function () {
      this._menu.innerHTML = ''

      this._items.forEach((item, idx) => {
        const li = document.createElement('li')
        li.className = 'autocomplete'
        li.dataset.index = idx
        li.setAttribute('role', 'option')
        li.innerHTML = `<a>${item.label_html} <span class="hoverme" data-person-id="${item.object_id}">...</span></a>`
        this._menu.appendChild(li)
      })

      originalRenderMenu()
    }

    input.addEventListener('keyup', () => {
      const input_term = input.value.trim()
      let last_name = TW.views.people.role_picker.get_last_name(input_term)
      let first_name = TW.views.people.role_picker.get_first_name(input_term)

      const newPerson = form.querySelector('.new_person')
      if (newPerson) {
        if (input_term.length === 0) {
          newPerson.setAttribute('hidden', 'true')
        } else {
          newPerson.removeAttribute('hidden')
        }
      }

      if (input_term.indexOf(',') > 1) {
        ;[first_name, last_name] = [last_name, first_name]
      }

      const firstNameInput = form.querySelector('.first_name')
      const lastNameInput = form.querySelector('.last_name')

      if (firstNameInput) {
        firstNameInput.value = first_name || ''
        firstNameInput.dispatchEvent(new Event('change'))
      }

      if (lastNameInput) {
        lastNameInput.value = last_name || ''
        lastNameInput.dispatchEvent(new Event('change'))
      }
    })
  },

  bind_new_link: function (form) {
    const link = form.querySelector('.role_picker_add_new')
    if (link) {
      link.addEventListener('click', (e) => {
        e.preventDefault()
        TW.views.people.role_picker.insert_new_person(form)
        const newPerson = form.querySelector('.new_person')
        if (newPerson) newPerson.setAttribute('hidden', 'true')
        TW.views.people.role_picker.clear_role_picker(form)
      })
    }
  },

  insert_existing_person: function (form, person_id, label) {
    const base_class = form.dataset.baseClass
    const random_index = Date.now()
    const role_list = form.querySelector('.role_list')

    const li = document.createElement('li')
    li.className = 'role_item'
    li.draggable = true
    li.style.cursor = 'move'
    li.dataset.roleIndex = random_index
    li.innerHTML = `
      ${label}&nbsp;
      <a href="#" class="remove_role">remove</a>
      <input type="hidden" name="${base_class}[roles_attributes][${random_index}][type]" value="${form.dataset.roleType}">
      <input type="hidden" name="${base_class}[roles_attributes][${random_index}][person_id]" value="${person_id}">
    `
    role_list.appendChild(li)
  },

  insert_new_person: function (form) {
    const base_class = form.dataset.baseClass
    const random_index = Date.now()
    const person_base = `${base_class}[roles_attributes][${random_index}][person_attributes]`
    const role_list = form.querySelector('.role_list')

    const firstName = form.querySelector('.first_name').value
    const lastName = form.querySelector('.last_name').value
    const suffix = form.querySelector('.suffix').value
    const prefix = form.querySelector('.prefix').value
    const label = form.querySelector('.name_label').textContent

    const li = document.createElement('li')
    li.className = 'role_item'
    li.dataset.newPerson = 'true'
    li.dataset.roleIndex = random_index
    li.innerHTML = `
      ${label}&nbsp;
      <input type="hidden" name="${base_class}[roles_attributes][${random_index}][type]" value="${form.dataset.roleType}">
      <input type="hidden" name="${person_base}[last_name]" value="${lastName}">
      <input type="hidden" name="${person_base}[first_name]" value="${firstName}">
      <input type="hidden" name="${person_base}[suffix]" value="${suffix}">
      <input type="hidden" name="${person_base}[prefix]" value="${prefix}">
      <a href="#" class="remove_role">remove</a>
    `
    role_list.appendChild(li)
  },

  bind_switch_link: function (form) {
    const link = form.querySelector('.role_picker_switch')
    if (link) {
      link.addEventListener('click', () => {
        const fn = form.querySelector('.first_name')
        const ln = form.querySelector('.last_name')
        if (fn && ln) {
          let tmp = fn.value
          fn.value = ln.value
          fn.dispatchEvent(new Event('change'))
          ln.value = tmp
          ln.dispatchEvent(new Event('change'))
        }
      })
    }
  },

  bind_expand_link: function (form) {
    const link = form.querySelector('.role_picker_expand')
    if (link) {
      link.addEventListener('click', () => {
        const details = form.querySelector('.role_picker_person_form')
        if (details) {
          details.style.display = details.style.display === 'none' ? '' : 'none'
        }
      })
    }
  },

  bind_label_mirroring: function (form) {
    const inputs = form.querySelectorAll('.role_picker_person_form input')
    inputs.forEach((inp) => {
      inp.addEventListener('input', () => {
        const fn = form.querySelector('.first_name')?.value || ''
        const ln = form.querySelector('.last_name')?.value || ''
        const lbl = form.querySelector('.name_label')
        if (lbl)
          lbl.innerHTML = TW.views.people.role_picker.get_full_name(fn, ln)
      })
    })
  },

  bind_hover: function (form) {
    document.querySelectorAll('.hoverme').forEach((el) => {
      el.addEventListener('mouseenter', async function () {
        const url = `/people/${this.dataset.personId}/details`
        const r = await fetch(url)
        const data = await r.text()
        const details = form.querySelector('.person_details')
        if (details) details.innerHTML = data
      })
      el.addEventListener('mouseleave', function () {
        const details = form.querySelector('.person_details')
        if (details) details.innerHTML = ''
      })
    })
  },

  bind_remove_links: function (links) {
    links.forEach((link) => {
      link.addEventListener('click', (e) => {
        e.preventDefault()
        const list_item = link.closest('li')
        const role_picker = list_item.closest('.role_picker')
        const role_id = list_item.dataset.roleId
        const role_index = list_item.dataset.roleIndex
        const base_class = role_picker.dataset.baseClass

        if (role_id !== undefined) {
          const role_list = list_item.closest('.role_list')
          if (list_item.dataset.newPerson !== 'true') {
            role_list.insertAdjacentHTML(
              'beforeend',
              `<input type="hidden" name="${base_class}[roles_attributes][${role_index}][id]" value="${role_id}">
               <input type="hidden" name="${base_class}[roles_attributes][${role_index}][_destroy]" value="1">`
            )
            TW.views.people.role_picker.warn_for_save(
              role_list.parentElement.querySelector('.role_picker_message')
            )
          }
        }
        list_item.remove()
      })
    })
  },

  warn_for_save: function (msg_div) {
    if (!msg_div) return
    msg_div.classList.add('warning')
    msg_div.innerHTML = 'Update required to confirm removal/reorder.'
  },

  make_role_list_sortable: function (form) {
    const list = form.querySelector('.role_list')
    if (!list) return

    if (list.dataset.sortableInitialized === 'true') return
    list.dataset.sortableInitialized = 'true'

    let draggingEl = null
    const placeholder = document.createElement('li')
    placeholder.className = 'role_item placeholder'
    placeholder.style.visibility = 'hidden'

    const setPlaceholderHeight = () => {
      const first = list.querySelector('.role_item:not(.placeholder)')
      placeholder.style.height = first
        ? `${first.getBoundingClientRect().height}px`
        : '40px'
    }

    function onDragStart(e) {
      draggingEl = e.currentTarget
      e.dataTransfer.effectAllowed = 'move'

      try {
        e.dataTransfer.setData('text/plain', '')
      } catch (err) {}
      draggingEl.classList.add('dragging')
      draggingEl.style.opacity = '0.4'
      setPlaceholderHeight()
    }

    function onDragOver(e) {
      e.preventDefault()
      const target = e.target.closest('.role_item')
      if (!target || target === draggingEl || target === placeholder) return

      const rect = target.getBoundingClientRect()
      const after = e.clientY - rect.top > rect.height / 2

      if (!placeholder.parentNode) {
        if (after) {
          target.parentNode.insertBefore(placeholder, target.nextSibling)
        } else {
          target.parentNode.insertBefore(placeholder, target)
        }
        return
      }

      if (after) {
        if (target.nextSibling !== placeholder)
          target.parentNode.insertBefore(placeholder, target.nextSibling)
      } else {
        if (target !== placeholder)
          target.parentNode.insertBefore(placeholder, target)
      }
    }

    function onDrop(e) {
      e.preventDefault()
      if (!draggingEl) return

      if (placeholder.parentNode) {
        placeholder.parentNode.replaceChild(draggingEl, placeholder)
      } else {
        list.appendChild(draggingEl)
      }

      cleanup()

      const msg = form.querySelector('.role_picker_message')
      if (
        msg &&
        typeof TW !== 'undefined' &&
        TW.views &&
        TW.views.people &&
        TW.views.people.role_picker &&
        typeof TW.views.people.role_picker.warn_for_save === 'function'
      ) {
        TW.views.people.role_picker.warn_for_save(msg)
      }
    }

    function onDragEnd() {
      cleanup()
    }

    function cleanup() {
      if (placeholder.parentNode)
        placeholder.parentNode.removeChild(placeholder)
      if (draggingEl) {
        draggingEl.classList.remove('dragging')
        draggingEl.style.opacity = ''
        draggingEl = null
      }
    }

    function enableDrag(item) {
      if (!item) return
      if (item.dataset.dragEnabled === 'true') return
      item.dataset.dragEnabled = 'true'

      item.setAttribute('draggable', 'true')
      item.addEventListener('dragstart', onDragStart, false)
      item.addEventListener('dragend', onDragEnd, false)
    }

    list.querySelectorAll('.role_item').forEach(enableDrag)
    list.addEventListener('dragover', onDragOver)
    list.addEventListener('drop', onDrop)

    const mo = new MutationObserver((mutations) => {
      for (const m of mutations) {
        if (m.type === 'childList' && m.addedNodes.length) {
          m.addedNodes.forEach((node) => {
            if (node.nodeType === 1) {
              if (node.matches && node.matches('.role_item')) {
                enableDrag(node)
              } else {
                node.querySelectorAll &&
                  node.querySelectorAll('.role_item').forEach(enableDrag)
              }
            }
          })
        }
      }
    })
    mo.observe(list, { childList: true, subtree: false })

    list._enableDrag = enableDrag
  },

  bind_position_handling_to_submit_button: function (form) {
    const base_class = form.dataset.baseClass
    const commitBtn = form.closest('form').querySelector('input[name="commit"]')
    if (commitBtn) {
      commitBtn.addEventListener('click', () => {
        let i = 1
        form.querySelectorAll('.role_item').forEach((item) => {
          const role_index = item.dataset.roleIndex
          item.insertAdjacentHTML(
            'beforeend',
            `<input type="hidden" name="${base_class}[roles_attributes][${role_index}][position]" value="${i}">`
          )
          i++
        })
      })
    }
  }
})

document.addEventListener('turbolinks:load', function () {
  document.querySelectorAll('.role_picker').forEach((el) => {
    const role_type = el.dataset.roleType
    TW.views.people.role_picker.initialize_role_picker(el, role_type)
  })
})
