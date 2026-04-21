function getRelativeElement(element) {
  const selector = element.getAttribute('data-relative-to')
  const target = selector && document.querySelector(selector)

  return document.querySelector(selector)
}

function getPositionRelativeToElement(element) {
  const target = getRelativeElement(element)

  return target ? target.getBoundingClientRect() : {}
}

function getClasses(element) {
  const classes = element.getAttribute('data-sticky-classes') || ''

  return ['sticky-navbar-fixed', ...classes.split(' ')].filter(Boolean)
}

function setSticky(element) {
  const { top = 0, height = 0 } = getPositionRelativeToElement(element)
  const positionY = top + height

  element.classList.add(...getClasses(element))
  element.style.setProperty('top', `${positionY}px`)
  element.parentElement.style.minHeight = `${element.clientHeight}px`
  element.style.maxHeight = `calc(100vh - ${element.offsetTop}px)`
}

function removeSticky(element) {
  const rect = element.getBoundingClientRect()

  element.classList.remove(...getClasses(element))
  element.style.removeProperty('top')
  element.parentElement.style.removeProperty('min-height')
  element.style.maxHeight = `calc(100vh - ${rect.top}px)`
}

export function setStickyNavbar(element) {
  const handleScroll = () => {
    const { scrollY } = window
    const { parentElement } = element
    const offsetTop = (getRelativeElement(element) || parentElement).offsetTop

    if (scrollY > offsetTop) {
      setSticky(element)
    } else {
      removeSticky(element)
    }

    element.style.width = `${parentElement.clientWidth}px`
  }

  const resizeNavbar = () => {
    element.style.width = `${element.parentElement.clientWidth}px`
    element.style.boxSizing = 'border-box'
    handleScroll()
  }

  window.addEventListener('resize', resizeNavbar)
  window.addEventListener('scroll', handleScroll)

  resizeNavbar()

  document.addEventListener('turbolinks:before-render', () => {
    window.removeEventListener('resize', resizeNavbar)
    window.removeEventListener('scroll', handleScroll)
  })
}

document.addEventListener('turbolinks:load', () => {
  const elements = document.querySelectorAll('.sticky-navbar')

  if (elements.length) {
    elements.forEach((el) => {
      setStickyNavbar(el)
    })
  }
})
