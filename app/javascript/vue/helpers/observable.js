export function onVisible(element, callback) {
  const options = {
    root: document.documentElement
  }

  const observer = new IntersectionObserver((entries, observer) => {
    entries.forEach((entry) => {
      callback(entry.intersectionRatio > 0)
    })
  }, options)

  observer.observe(element)

  return {
    observer
  }
}
