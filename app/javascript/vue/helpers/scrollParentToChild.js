export default (parent, child) => {
  const parentRect = parent.getBoundingClientRect()
  const parentViewableArea = {
    height: parent.clientHeight,
    width: parent.clientWidth
  }

  const childRect = child.getBoundingClientRect()
  const isViewable = (childRect.top >= parentRect.top) && (childRect.top <= parentRect.top + parentViewableArea.height)

  if (!isViewable) {
    parent.scrollTop = (childRect.top + parent.scrollTop) - parentRect.top
  }
}
