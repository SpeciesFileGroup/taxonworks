export const vResizeColumn = {
  mounted: (el, binding) => {
    if (el.nodeName !== 'TABLE') { return console.error('This directive is only valid on a table!') }

    const opt = binding.value || {}
    const table = el
    const thead = table.querySelector('thead')
    const ths = thead.querySelectorAll('th')

    const handleResize = e => {
      const dx = e.x - currentPosition

      activeTh.style.width = `${parseInt(getComputedStyle(activeTh, '').width) + dx}px`
      activeTh.style.minWidth = `${parseInt(getComputedStyle(activeTh, '').width) + dx}px`

      currentPosition = e.x
    }

    let activeTh = null
    let currentPosition = null

    ths.forEach(th => {
      const bar = document.createElement('div')

      th.style.position = 'relative'
      th.originalWidth = th.style.width

      bar.style.position = 'absolute'
      bar.style.cursor = 'col-resize'
      bar.style.right = 0
      bar.style.top = 0
      bar.style.bottom = 0
      bar.style.width = opt.handleWidth || '8px'
      bar.style.zIndex = opt.zIndex || 1
      bar.className = opt.handleClass || 'vue-column-resize-bar'

      bar.addEventListener('click', e => { e.stopPropagation() })
      bar.addEventListener('mousedown', e => {
        e.stopPropagation()
        if (e.target.parentElement.getAttribute('fixedsize')) {
          return
        }
        currentPosition = e.x
        document.body.addEventListener('mousemove', handleResize)
        document.body.style.cursor = 'col-resize'
        document.body.style.userSelect = 'none'

        activeTh = e.target.parentElement
      })

      th.appendChild(bar)
    })

    document.addEventListener('mouseup', () => {
      document.body.removeEventListener('mousemove', handleResize)
      document.body.style.cursor = ''
      document.body.style.userSelect = ''
      if (typeof opt.afterResize === 'function') {
        opt.afterResize(ths)
      }
    })
  }
}
