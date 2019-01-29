import Vue from 'vue'
import VueResource from 'vue-resource'

Vue.use(VueResource)


const ajaxCall = function (type, url, data = null) {
  Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  return new Promise(function (resolve, reject) {
    Vue.http[type](url, data).then(response => {
      console.log(response)
      return resolve(response.body)
    }, response => {
      console.log(response)
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

const GetPredicates = function () {
  return ajaxCall('get', '/controlled_vocabulary_terms?type[]=Predicate')
}

const GetProjectPreferences = function () {
  return ajaxCall('get', `/project_preferences.json`)
}

const UpdateProjectPreferences = function (id, preferences) {
  return ajaxCall('patch', `/projects/${id}.json`, { project: preferences })
}

const CreateControlledVocabularyTerm = function (label) {
  return ajaxCall('post', `/controlled_vocabulary_terms`, { controlled_vocabulary_term: label })
}

export {
  CreateControlledVocabularyTerm,
  GetPredicates,
  GetProjectPreferences,
  UpdateProjectPreferences
}