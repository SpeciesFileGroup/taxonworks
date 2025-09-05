function getPositionRelativeToElement(element) {
  const selector = element.getAttribute('data-relative-to')
  const target = selector && document.querySelector(selector)

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
}

function removeSticky(element) {
  element.classList.remove(...getClasses(element))
  element.style.removeProperty('top')
}

export function setStickyNavbar(element) {
  const handleScroll = () => {
    const { scrollY } = window

    if (scrollY > element.parentElement.offsetTop) {
      setSticky(element)
    } else {
      removeSticky(element)
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
  const elements = document.querySelectorAll('.sticky-navbar')

  if (elements.length) {
    elements.forEach((el) => {
      setStickyNavbar(el)
    })
  }
})
