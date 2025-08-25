import { Lead as LeadEndpoint } from '@/routes/endpoints'
import { useUserOkayToLeave } from './useUserOkayToLeave.js'

export function useInsertCouplet(
  parentId, loadingRef, store, successCallback = () => {}
) {
  if (!useUserOkayToLeave(store) ||
    !window.confirm(
      'Insert a couplet below this one? Any existing children will be reparented.'
    )
  ) {
    return
  }

  loadingRef.value = true
  LeadEndpoint.insert_couplet(parentId)
    .then(() => {
      successCallback()
    })
    .catch(() => {})
    .finally(() => {
      loadingRef.value = false
    })
}
