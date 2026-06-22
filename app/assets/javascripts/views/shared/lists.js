;(function () {
  window.TW = window.TW || {}
  TW.views = TW.views || {}
  TW.views.shared = TW.views.shared || {}
  TW.views.shared.list = TW.views.shared.list || {}

  function init() {
    addActionsHeader()
    addColumnsDropdown()
    wrapTableInCard()
    initRowDoubleClick()
    initPaginationShortcuts()
    orderLists()
  }

  function wrapTableInCard() {
    var table = document.querySelector('#main .tablesorter')
    if (!table) return

    var parent = table.parentNode
    if (parent.classList && parent.classList.contains('tw-card')) return

    var card = document.createElement('div')
    card.className = 'tw-card table-card'
    parent.insertBefore(card, table)
    card.appendChild(table)
  }

  function initRowDoubleClick() {
    document.querySelectorAll('tbody tr').forEach(function (row) {
      row.addEventListener('dblclick', function () {
        var link = row.querySelector('a[data-show]')
        if (link) location.href = link.getAttribute('href')
      })
    })
  }

  function addColumnsDropdown() {
    var table = document.querySelector('#main .tablesorter')
    var actions = document.querySelector('#nav-list .list-actions')
    if (!table || !actions || document.querySelector('#displayOptions')) return

    var groups = uniqueGroups(table)
    if (groups.length === 0) return

    var items = groups
      .map(function (group) {
        return (
          '<label class="columns-menu-item" data-group="' +
          group +
          '"><input type="checkbox" class="columns-checkbox" checked>' +
          '<span class="col-label">' +
          group +
          '</span></label>'
        )
      })
      .join('')

    actions.insertAdjacentHTML(
      'afterbegin',
      '<div id="displayOptions" class="columns-dropdown" data-help="Show or hide column groups.">' +
        '<button type="button" class="columns-toggle button btn-outline btn-medium-size">Columns</button>' +
        '<div class="columns-menu">' +
        items +
        '</div></div>'
    )

    wireColumnsDropdown()
  }

  function uniqueGroups(table) {
    var groups = []
    table.querySelectorAll('thead th[data-group]').forEach(function (th) {
      var group = th.getAttribute('data-group')
      if (group && group !== 'null' && groups.indexOf(group) === -1) {
        groups.push(group)
      }
    })
    return groups
  }

  function wireColumnsDropdown() {
    var dropdown = document.querySelector('#displayOptions')
    if (!dropdown) return

    var table = document.querySelector('#main .tablesorter')

    dropdown
      .querySelector('.columns-toggle')
      .addEventListener('click', function (event) {
        event.stopPropagation()
        dropdown.classList.toggle('open')
      })

    dropdown.querySelectorAll('.columns-checkbox').forEach(function (checkbox) {
      checkbox.addEventListener('change', function () {
        var group = checkbox.closest('[data-group]').getAttribute('data-group')
        setGroupVisible(table, group, checkbox.checked)
      })
    })

    document.removeEventListener('click', closeColumnsMenuOnOutsideClick)
    document.addEventListener('click', closeColumnsMenuOnOutsideClick)
  }

  function closeColumnsMenuOnOutsideClick(event) {
    var dropdown = document.querySelector('#displayOptions')
    if (dropdown && !dropdown.contains(event.target)) {
      dropdown.classList.remove('open')
    }
  }

  function setGroupVisible(table, group, show) {
    if (!table) return
    table
      .querySelectorAll('thead th[data-group="' + group + '"]')
      .forEach(function (th) {
        var column = th.cellIndex + 1
        table
          .querySelectorAll('tr > :nth-child(' + column + ')')
          .forEach(function (cell) {
            cell.style.display = show ? '' : 'none'
          })
      })
  }

  function initPaginationShortcuts() {
    TW.workbench.keyboard.createShortcut(
      'left',
      'Go to previous page',
      'Lists',
      function () {
        var prev = document.querySelector('.pagination a[rel="prev"]')
        if (prev) location.href = prev.getAttribute('href')
      }
    )

    TW.workbench.keyboard.createShortcut(
      'right',
      'Go to next page',
      'Lists',
      function () {
        var next = document.querySelector('.pagination a[rel="next"]')
        if (next) location.href = next.getAttribute('href')
      }
    )
  }

  function addActionsHeader() {
    document.querySelectorAll('#main .tablesorter').forEach(function (table) {
      var headerRow = table.querySelector('thead tr')
      if (
        headerRow &&
        table.querySelector('tbody .row-actions') &&
        !table.querySelector('.row-actions-th')
      ) {
        headerRow.insertAdjacentHTML(
          'beforeend',
          '<th class="row-actions-th sorter-false"></th>'
        )
      }
    })
  }

  function orderLists() {
    var jq = window.jQuery
    if (!jq) return

    document.querySelectorAll('table').forEach(function (table) {
      var options = { widgets: ['zebra'] }

      if (table.querySelector('.row-actions-th')) {
        var lastIndex = table.querySelectorAll('thead th').length - 1
        options.headers = {}
        options.headers[lastIndex] = { sorter: false }
      }

      jq(table).tablesorter(options)
    })
  }

  document.addEventListener('turbolinks:load', function () {
    if (document.querySelector('#main .tablesorter')) init()
  })

  TW.views.shared.list.init = init
})()
