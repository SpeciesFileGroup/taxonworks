export default function (url, param, value) {
  let urlParams = new URLSearchParams(window.location.search)
  if (value) {
    urlParams.set(param, value)
  } else {
    urlParams.delete(param)
  }
  history.pushState(null, null, `${url}?${urlParams.toString()}`)
}