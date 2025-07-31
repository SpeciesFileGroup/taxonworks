var TW = TW || {}
TW.views = TW.views || {}
TW.views.shared = TW.views.shared || {}
TW.views.shared.recent_updates = TW.views.shared.recent_updates || {}

Object.assign(TW.views.shared.recent_updates, {
  init: function () {
    const listElements = [...document.querySelectorAll('.recent_updates li')]

    listElements.forEach((el) =>
      el.addEventListener('dblclick', function (e) {
        location.href = this.querySelector('a').getAttribute('href')
      })
    )

    this.opacityUpdates()
    recentUpdatesContextMenu()

    function recentUpdatesContextMenu() {
      $.contextMenu('destroy', '.recent_updates li')
      $.contextMenu({
        selector: '.recent_updates li',
        autoHide: true,
        callback: function (key, options) {
          console.log(options)
          switch (key) {
            case 'show':
              location.href = options.$trigger
                .find('div:nth-child(1) a:nth-child(1)')
                .attr('href')
              break
            case 'edit':
              location.href = options.$trigger
                .find('div:nth-child(2) a:nth-child(1)')
                .attr('href')
          }
        },
        items: {
          show: { name: 'Show', icon: 'show' },
          sep1: '---------',
          edit: { name: 'Edit', icon: 'edit' }
        }
      })
    }
  },

  opacityUpdates: function () {
    var childs = $('.recent_updates ul').children().length,
      opacityValue = 1

    for (var i = 1; i <= childs; i++) {
      $('.recent_updates li:nth-child(' + i + ')').css(
        'opacity',
        opacityValue - i * 0.1
      )
    }
  }
})

$(document).on('turbolinks:load', function () {
  if ($('#model_index').length) {
    TW.views.shared.recent_updates.init()
  }
})
