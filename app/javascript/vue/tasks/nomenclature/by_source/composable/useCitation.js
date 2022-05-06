import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../store/getters/getters.js'
import { ActionNames } from '../store/actions/actions.js'
import getPagination from 'helpers/getPagination.js'

export default type => {
  const store = useStore()
  const citations = computed(() => store.getters[GetterNames.GetCitationsByType](type))
  const isLoading = ref(false)
  const pagination = ref(null)
 
  const requestCitations = ({ page, per, sourceId }) => {
    isLoading.value = true
    store.dispatch(ActionNames.LoadCitations, { 
      type,
      sourceId,
      page,
      per
    }).then(response => { 
      pagination.value = getPagination(response)
      isLoading.value = false
    })
  }

  const loadOtuByProxy = param => {
    store.dispatch(ActionNames.LoadOtuByProxy, {
      list: citations.value,
      param
    })
  }

  return {
    citations,
    isLoading,
    getPagination,
    loadOtuByProxy,
    pagination,
    requestCitations,
  }
}