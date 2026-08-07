function initialize_citation_topic_picker(form) {
  function insert_existing_topic2(form, topic_id, label) {
    const base_class = 'citation'
    const random_index = new Date().getTime()
    const citation_topic_list = form.querySelector('.citation_topic_list')

    const hidden_input = document.createElement('input')

    hidden_input.type = 'hidden'
    hidden_input.name = `${base_class}[citation_topics_attributes][${random_index}][topic_id]`
    hidden_input.value = topic_id
    citation_topic_list.appendChild(hidden_input)

    const li = document.createElement('li')

    li.className = 'citation_topic_item'
    li.dataset.citationTopicIndex = random_index
    li.innerHTML = label + '&nbsp;'
    li.appendChild(remove_citation_topic_link())
    citation_topic_list.appendChild(li)
  }

  function clear_citation_topic_picker(form) {
    const autocomplete_input = form.querySelector(
      '.citation_topic_autocomplete'
    )
    if (autocomplete_input) autocomplete_input.value = ''
    const new_topic_div = form.querySelector('.new_topic')
    if (new_topic_div) new_topic_div.hidden = true
  }

  function initialize_citation_topic_autocomplete(form) {
    const input = form.querySelector('.citation_topic_autocomplete')
    if (!input) return

    const ac = new TWAutocomplete(input, {
      source: function (term, respond) {
        fetch('/topics/lookup_topic?term=' + encodeURIComponent(term))
          .then((r) => r.json())
          .then((data) => respond(data))
          .catch(() => respond([]))
      },
      minLength: 1,

      select: function (ui) {
        insert_existing_topic2(form, ui.item.object_id, ui.item.label)
        clear_citation_topic_picker(form)
        this.close()
      }
    })

    const originalRenderMenu = ac._renderMenu.bind(ac)

    ac._renderMenu = function () {
      this._menu.innerHTML = ''
      const term = this.input.value

      this._items.forEach((item, idx) => {
        const li = document.createElement('li')
        li.className = 'autocomplete'
        li.setAttribute('data-index', idx)
        li.setAttribute('role', 'option')
        li.innerHTML = '<a>' + item.label + '</a>'
        this._menu.appendChild(li)
      })

      originalRenderMenu()
    }

    input.addEventListener('keyup', () => {
      const input_term = input.value
      const new_topic_div = form.querySelector('.new_topic')
      if (new_topic_div) new_topic_div.hidden = input_term.length === 0

      const name_input = form.querySelector('.name')
      const definition_input = form.querySelector('.definition')
      if (name_input) name_input.value = input_term
      if (definition_input) definition_input.value = ''
    })
  }

  function bind_definition_listener(form) {
    const definition_input = form.querySelector('.definition')
    if (!definition_input) return

    definition_input.addEventListener('keyup', () => {
      const btn = form.querySelector('.citation_topic_picker_add_new')
      if (!btn) return
      btn.style.display = definition_input.value.length === 0 ? 'none' : 'flex'
    })
  }

  function bind_new_topic_link(form) {
    const add_btn = form.querySelector('.citation_topic_picker_add_new')
    if (!add_btn) return

    add_btn.addEventListener('click', () => {
      insert_new_topic(form)
      const new_topic_div = form.querySelector('.new_topic')
      if (new_topic_div) new_topic_div.hidden = true
      clear_citation_topic_picker(form)
    })
  }

  function insert_new_topic(form) {
    const base_class = 'citation'
    const random_index = new Date().getTime()
    const citation_topic_base = `${base_class}[citation_topics_attributes][${random_index}]`
    const topic_base = `${citation_topic_base}[topic_attributes]`
    const citation_topic_list = form.querySelector('.citation_topic_list')

    const name = escapeHtml(
      form.querySelector('.citation_topic_autocomplete').value
    )
    const definition = escapeHtml(form.querySelector('.definition').value)

    const li = document.createElement('li')
    li.className = 'citation_topic_item'
    li.dataset.newTopic = 'true'
    li.dataset.topicIndex = random_index

    li.innerHTML = `<div><div>${name}</div><input name="${citation_topic_base}[pages]" placeholder="Pages"></div>`
    const hidden_name = document.createElement('input')
    hidden_name.type = 'hidden'
    hidden_name.name = `${topic_base}[name]`
    hidden_name.value = name

    const hidden_def = document.createElement('input')
    hidden_def.type = 'hidden'
    hidden_def.name = `${topic_base}[definition]`
    hidden_def.value = definition

    li.appendChild(hidden_name)
    li.appendChild(hidden_def)
    li.appendChild(remove_citation_topic_link())

    citation_topic_list.appendChild(li)

    const add_btn = form.querySelector('.citation_topic_picker_add_new')
    if (add_btn) add_btn.style.display = 'none'
  }

  function remove_citation_topic_link() {
    const link = document.createElement('a')
    link.href = '#'
    link.dataset.turbolinks = 'false'
    link.className = 'remove_citation_topic delete-circle'
    link.textContent = 'remove'
    bind_remove_citation_topic_links(link)
    return link
  }

  function bind_topic_label_mirroring(form) {
    const inputs = form.querySelectorAll(
      '.citation_topic_picker_topic_form input'
    )
    inputs.forEach((input) => {
      input.addEventListener('input', () => {
        const label = form.querySelector('.name_label')
        const name_input = form.querySelector('.name')
        if (label && name_input) label.textContent = name_input.value
      })
    })
  }

  function bind_remove_citation_topic_links(links) {
    if (!links) return
    const elems =
      links instanceof NodeList || Array.isArray(links) ? links : [links]
    elems.forEach((link) => {
      link.addEventListener('click', (e) => {
        e.preventDefault()
        const list_item = link.closest('li')
        const citation_topic_picker = list_item.closest(
          '.citation_topic_picker'
        )
        const citation_topic_id = list_item.dataset.citationTopicId
        const citation_topic_index = list_item.dataset.citationTopicIndex
        const base_class = 'citation'

        if (citation_topic_id !== undefined) {
          const citation_topic_list = list_item.closest('.citation_topic_list')
          if (list_item.dataset.newTopic !== 'true') {
            const id_input = document.createElement('input')
            id_input.type = 'hidden'
            id_input.name = `${base_class}[citation_topics_attributes][${citation_topic_index}][id]`
            id_input.value = citation_topic_id

            const destroy_input = document.createElement('input')
            destroy_input.type = 'hidden'
            destroy_input.name = `${base_class}[citation_topics_attributes][${citation_topic_index}][_destroy]`
            destroy_input.value = '1'

            citation_topic_list.appendChild(id_input)
            citation_topic_list.appendChild(destroy_input)

            const msg_div = citation_topic_list.parentElement.querySelector(
              '.citation_topic_picker_message'
            )
            if (msg_div) warn_for_citation_topic_save(msg_div)
          }
        }
        list_item.remove()
      })
    })
  }

  function warn_for_citation_topic_save(msg_div) {
    msg_div.classList.add('warning')
    msg_div.textContent = 'Update required to confirm removal/reorder.'
  }

  function escapeHtml(str) {
    const div = document.createElement('div')
    div.textContent = str
    return div.innerHTML
  }

  initialize_citation_topic_autocomplete(form)
  bind_new_topic_link(form)
  bind_topic_label_mirroring(form)
  bind_remove_citation_topic_links(
    form.querySelectorAll('.remove_citation_topic')
  )
  bind_definition_listener(form)
}

document.addEventListener('turbolinks:load', () => {
  document.querySelectorAll('.citation_topic_picker').forEach((form) => {
    initialize_citation_topic_picker(form)
  })
})
