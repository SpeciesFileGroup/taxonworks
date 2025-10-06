import { URLParamsToJSON } from '@/helpers/url/parse'

// paramVarsHash, like {matrix_id: 'matrixId', otu_ids: 'otuIds'}
// sessionPrefix, whatever prefx was used to uniquify these param keys in the
//   session store
export function useParamsSessionPop(paramVarsHash, sessionPrefix) {
  let h = {}

  const urlParams = URLParamsToJSON(location.href)
  Object.entries(paramVarsHash).forEach(([key, varr]) => {
    let value = null
    if (value = urlParams[key]) { // Least surprising/confusing to have this first
      h[varr] = value
    }
    else if (value = sessionStorage.getItem(sessionPrefix + '_' + key)) {
      h[varr] = value
      sessionStorage.removeItem(sessionPrefix + '_' + key)
    } else {
      h[varr] = undefined
    }
  })

  return h
}