<template>
  <CustomAttributes
    v-if="projectPreferences"
    ref="customAttributeRef"
    :object-id="collectionObject.id"
    :object-type="COLLECTION_OBJECT"
    :model="COLLECTION_OBJECT"
    :model-preferences="
      projectPreferences.model_predicate_sets.CollectionObject
    "
    @on-update="setAttributes"
  />
</template>

<script setup>
import CustomAttributes from '@/components/custom_attributes/predicates/predicates'
import { COLLECTION_OBJECT } from '@/constants'
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters.js'
import { ActionNames } from '../../store/actions/actions.js'
import { computed, onBeforeUnmount, ref } from 'vue'
import { useStore } from 'vuex'

const store = useStore()
const customAttributeRef = ref()

const collectionObject = computed({
  get: () => store.getters[GetterNames.GetCollectionObject],
  set: (value) => store.commit(MutationNames.SetCollectionObject, value)
})

const projectPreferences = computed(
  () => store.getters[GetterNames.GetProjectPreferences]
)

const unsubscribe = store.subscribeAction({
  after: (action) => {
    if (action.type === ActionNames.SaveCollectionObject) {
      customAttributeRef.value.loadDataAttributes()
    }
    if (action.type === ActionNames.ResetStore) {
      customAttributeRef.value.resetRows()
    }
  }
})

onBeforeUnmount(() => {
  unsubscribe()
})

function setAttributes(dataAttributes) {
  collectionObject.value.data_attributes_attributes = dataAttributes
}
</script>
