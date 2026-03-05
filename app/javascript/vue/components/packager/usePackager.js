import { onBeforeMount, ref } from 'vue'
import qs from 'qs'
import ajaxCall from '@/helpers/ajaxCall'
import { LinkerStorage } from '@/shared/Filter/utils'
import { randomUUID } from '@/helpers'
import { createAndSubmitForm } from '@/helpers/forms'
import { MAX_MAX_MB } from './utils'

export function usePackager({
  previewUrl,
  downloadUrl,
  filterRoute,
  storageKey,
  storageStateParam,
  payloadKey,
  loadErrorMessage
}) {
  const sessionKey = `${storageKey}-session`
  const isLoading = ref(false)
  const groups = ref([])
  const items = ref([])
  const errorMessage = ref('')
  const filterParams = ref(null)
  const maxBytes = ref(0)
  const maxMb = ref(MAX_MAX_MB)

  function loadPreview(params) {
    isLoading.value = true
    errorMessage.value = ''

    ajaxCall('post', previewUrl, {
      ...params,
      max_mb: maxMb.value
    })
      .then(({ body }) => {
        items.value = body[payloadKey] || []
        groups.value = body.groups || []
        filterParams.value = body.filter_params || null
        maxBytes.value = body.max_bytes || 0
        if (filterParams.value && Object.keys(filterParams.value).length) {
          sessionStorage.setItem(sessionKey, JSON.stringify(filterParams.value))
        } else {
          sessionStorage.removeItem(sessionKey)
        }
      })
      .catch(() => {
        errorMessage.value = loadErrorMessage
      })
      .finally(() => {
        isLoading.value = false
      })
  }

  function refreshPreview() {
    if (!filterParams.value) return
    loadPreview(filterParams.value)
  }

  function initializeFromParams() {
    const stored = LinkerStorage.getParameters() || {}
    const params = {
      ...qs.parse(window.location.search, { ignoreQueryPrefix: true, arrayLimit: 2500 }),
      ...stored
    }

    LinkerStorage.removeParameters()

    if (!Object.keys(params).length) {
      const cached = sessionStorage.getItem(sessionKey)
      if (cached) {
        const parsed = JSON.parse(cached)
        if (Object.keys(parsed).length) {
          loadPreview(parsed)
          return
        }
      }

      errorMessage.value = 'no-params'
      return
    }

    loadPreview(params)
  }

  function downloadGroup(index) {
    createAndSubmitForm({
      action: downloadUrl,
      data: {
        ...(filterParams.value || {}),
        group: index,
        max_mb: maxMb.value
      },
      openTab: true,
      openTabStrategy: 'target'
    })
  }

  function goBackToFilter() {
    if (!filterParams.value) return

    const uuid = randomUUID()
    localStorage.setItem(storageKey, JSON.stringify({ [uuid]: filterParams.value }))
    window.location.href = `${filterRoute}?${storageStateParam}=${uuid}`
  }

  onBeforeMount(initializeFromParams)

  return {
    isLoading,
    groups,
    items,
    errorMessage,
    filterParams,
    maxBytes,
    maxMb,
    refreshPreview,
    downloadGroup,
    goBackToFilter
  }
}
