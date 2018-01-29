export default function (param, id) {
  let urlParams = new URLSearchParams(window.location.search)
  if (id) {
    urlParams.set(param, id)
  } else {
    urlParams.delete(param)
  }
  history.pushState(null, null, `/tasks/type_material/edit_type_material?${urlParams.toString()}`)
}
