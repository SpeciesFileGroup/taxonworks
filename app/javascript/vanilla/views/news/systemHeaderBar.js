function getClosedNews() {
  const c = document.cookie.match(/(?:^|; )closed_news=([^;]*)/)
  return c ? JSON.parse(decodeURIComponent(c[1])) : []
}

function setClosedNews(ids) {
  document.cookie = `closed_news=${encodeURIComponent(
    JSON.stringify(ids)
  )}; path=/; max-age=31536000`
}

document.addEventListener('turbolinks:load', () => {
  const btns = [...document.querySelectorAll('.news-bar-close-button')]

  if (btns.length) {
    btns.forEach((closeBtn) =>
      closeBtn.addEventListener(
        'click',
        () => {
          const newsId = closeBtn.getAttribute('data-news-id')
          const closed = getClosedNews()

          if (newsId) {
            closed.push(Number(newsId))
            setClosedNews(closed)
          }

          console.log(closed)
          closeBtn.parentNode.remove()
        },
        { once: true }
      )
    )
  }
})
