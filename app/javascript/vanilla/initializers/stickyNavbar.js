export function setStickyNavbar(element) {
  const handleScroll = () => {
    const { scrollY } = window

    if (scrollY > element.parentElement.offsetTop) {
      element.classList.add('sticky-navbar-fixed')
    } else {
      element.classList.remove('sticky-navbar-fixed')
    }

    element.parentElement.style.minHeight = `${element.clientHeight}px`
    element.style.width = `${element.parentElement.clientWidth}px`
  }

  const resizeNavbar = () => {
    element.style.width = `${element.parentElement.clientWidth}px`
    element.style.boxSizing = 'border-box'
  }

  window.addEventListener('resize', resizeNavbar)
  window.addEventListener('scroll', handleScroll)

  document.addEventListener('turbolinks:before-render', () => {
    window.removeEventListener('resize', resizeNavbar)
    window.removeEventListener('scroll', handleScroll)
  })
}

document.addEventListener('turbolinks:load', () => {
  const element = document.querySelector('.sticky-navbar')

  if (document.querySelector('.sticky-navbar')) {
    setStickyNavbar(element)
  }
})
