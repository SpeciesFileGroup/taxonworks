export default function () {
  return (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt')
}