var TW = TW || {}
TW.views = TW.views || {}
TW.views.hub = TW.views.hub || {}
TW.views.hub.favorites = TW.views.hub.favorites || {}

Object.assign(TW.views.hub.favorites, {
  init: function () {
    document
      .querySelectorAll('.task-section .unfavorite_link')
      .forEach((link) => {
        link.addEventListener('click', function () {
          const card = this.closest('.task_card')
          if (card) card.remove()
        })
      })

    document
      .querySelectorAll('.data_section .unfavorite_link')
      .forEach((link) => {
        link.addEventListener('click', function () {
          const card = this.closest('.card-container')
          if (card) card.remove()
        })
      })
  }
})

document.addEventListener('turbolinks:load', function () {
  if (document.getElementById('favorite-page')) {
    TW.views.hub.favorites.init()
  }
})
