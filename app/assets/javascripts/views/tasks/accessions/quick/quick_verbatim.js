document.addEventListener('turbolinks:load', function () {
  const quickTask = document.getElementById('quick_task')
  if (quickTask) {
    const groups = document.querySelectorAll('.biocuration_group_totals')

    groups.forEach((group) => {
      const addRow = group.querySelector('.add_total_row')
      const target = group.querySelector('.one_third_width')

      if (addRow && target) {
        target.appendChild(addRow)
      }
    })
  }
})
