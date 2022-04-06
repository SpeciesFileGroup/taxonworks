import { ref } from 'vue'
import {
  Attribution,
  CollectingEvent,
  CollectionObject,
  Extract,
  Georeference,
  Loan,
  Source,
  TaxonDetermination,
  TaxonName
} from 'routes/endpoints'

const requestObject = {
  Attribution,
  CollectingEvent,
  CollectionObject,
  Extract,
  Georeference,
  Loan,
  Source,
  TaxonDetermination,
  TaxonName
}

export default roles => {
  const roleObjects = ref([])
  const isLoading = ref(true)
  const requests = roles.map(r => requestObject[r.role_object_type].find(r.role_object_id))

  Promise.allSettled(requests).then(responses => {
    isLoading.value = false
    roleObjects.value = responses
      .filter(r => r.status === 'fulfilled')
      .map(r => r.value.body)
  })

  return [
    isLoading,
    roleObjects
  ]
}
