// quick_verbatim_material_task.js

function update_attribute_names() {
  const new_id = Date.now()
  const regex = /_update_/g
  const inputs = document.querySelectorAll('input[name*="_update_"]')

  inputs.forEach((input) => {
    const newName = input.name.replace(regex, new_id)
    const newId = input.id.replace(regex, new_id)
    input.name = newName
    input.id = newId
  })
}

function bind_remove_row_link() {
  const links = document.querySelectorAll('a[class*="_update_"]')

  links.forEach((el) => {
    el.addEventListener('click', function (event) {
      const row = el.closest('.biocuration_totals_row')
      if (row) row.style.display = 'none'
      event.preventDefault()
    })

    el.className = 'remove_row'
  })
}

document.addEventListener('turbolinks:load', function () {
  const addButtons = document.querySelectorAll('.add_total_row')

  addButtons.forEach((btn) => {
    btn.addEventListener('click', function (event) {
      update_attribute_names(btn)
      bind_remove_row_link(btn)
    })
  })
})
