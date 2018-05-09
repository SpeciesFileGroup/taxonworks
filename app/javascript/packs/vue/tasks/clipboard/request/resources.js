import Vue from 'vue'
import VueResource from 'vue-resource'

Vue.use(VueResource)
Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

const ajaxCall = function (type, url, data = null) {
  return new Promise(function (resolve, reject) {
    console.log(data)
    Vue.http[type](url, data).then(response => {
      console.log(response)
      return resolve(response.body)
    }, response => {
      handleError(response.body)
      return reject(response)
    })
  })
}

const handleError = function (json) {
  if (typeof json !== 'object') return
  let errors = Object.keys(json)
  let errorMessage = ''

  errors.forEach(function (item) {
    errorMessage += json[item].join('<br>')
  })

  TW.workbench.alert.create(errorMessage, 'error')
}

const UpdateClipboard = function (clipboard) {
  //project_member[clipboard]={}
  return ajaxCall('put', `/project_members/update_clipboard.json`, { project_member: { clipboard: clipboard } })
}

const GetClipboard = function () {
  return ajaxCall('get', `/project_members/clipboard.json`)
}

export {
  GetClipboard,
  UpdateClipboard
}