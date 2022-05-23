import { computed, ref, watch } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../store/getters/getters.js'
import { ActionNames } from '../store/actions/actions.js'
import getPagination from 'helpers/getPagination.js'

export default (type) => {
  const store = useStore()
  const citations = computed(() => store.getters[GetterNames.GetCitationsByType](type))
  const isLoading = ref(false)
  const pagination = ref(null)
  const per = ref(500)
  const sourceId = computed(() => store.getters[GetterNames.GetSource].id)
 
  const requestCitations = ({ page, per }) => {
    isLoading.value = true
    store.dispatch(ActionNames.LoadCitations, { 
      sourceId: sourceId.value,
      type,
      page,
      per
    }).then(response => { 
      pagination.value = getPagination(response)
      isLoading.value = false
    })
  }

  watch(
    [sourceId, per],
    id => {
      requestCitations({
        sourceId: id,
        page: 1,
        per: per.value
      })
    }
  )

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
    per,
    requestCitations
  }
}