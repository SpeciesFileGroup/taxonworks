const DEFAULT_OFFSET_REFERENCE = '#header-wrapper'

function getReferenceElement(element) {
  const selector =
    element.getAttribute('data-relative-to') || DEFAULT_OFFSET_REFERENCE

  return selector ? document.querySelector(selector) : null
}

function getReferenceOffset(element) {
  const reference = getReferenceElement(element)

  if (!reference) return 0

  const isReferenceFixed = getComputedStyle(reference).position === 'fixed'

  if (!isReferenceFixed) return 0

  return reference.getBoundingClientRect().bottom
}

function getClasses(element) {
  const classes = element.getAttribute('data-sticky-classes') || ''

  return ['sticky-navbar-fixed', ...classes.split(' ')].filter(Boolean)
}

function getOriginalPosition(element) {
  const { parentElement } = element

  return parentElement.getBoundingClientRect().top + window.scrollY
}

function setSticky(element, offset) {
  element.classList.add(...getClasses(element))
  element.style.setProperty('top', `${offset}px`)
  element.parentElement.style.minHeight = `${element.clientHeight}px`
  element.style.maxHeight = `calc(100vh - ${offset}px)`
}

function removeSticky(element) {
  element.classList.remove(...getClasses(element))
  element.style.removeProperty('top')
  element.style.removeProperty('max-height')
  element.parentElement.style.removeProperty('min-height')
}

export function setStickyNavbar(element) {
  let observers = []

  const update = () => {
    const offset = getReferenceOffset(element)
    const originalPosition = getOriginalPosition(element)

    if (window.scrollY + offset > originalPosition) {
      setSticky(element, offset)
    } else {
      removeSticky(element)
    }

    element.style.width = `${element.parentElement.clientWidth}px`
    element.style.boxSizing = 'border-box'
  }

  const disconnectObservers = () => {
    observers.forEach((observer) => observer.disconnect())
    observers = []
  }

  const observeReference = () => {
    disconnectObservers()

    const reference = getReferenceElement(element)

    if (!reference) return

    const resizeObserver = new ResizeObserver(update)
    resizeObserver.observe(reference)

    const mutationObserver = new MutationObserver(() => {
      requestAnimationFrame(update)
    })
    mutationObserver.observe(reference, {
      attributes: true,
      attributeFilter: ['class', 'style']
    })

    observers.push(resizeObserver, mutationObserver)
  }

  window.addEventListener('resize', update)
  window.addEventListener('scroll', update)

  observeReference()
  update()

  document.addEventListener(
    'turbolinks:before-render',
    () => {
      window.removeEventListener('resize', update)
      window.removeEventListener('scroll', update)
      disconnectObservers()
    },
    { once: true }
  )
}

document.addEventListener('turbolinks:load', () => {
  const elements = document.querySelectorAll('.sticky-navbar')

  if (elements.length) {
    elements.forEach((el) => {
      setStickyNavbar(el)
    })
  }
})
