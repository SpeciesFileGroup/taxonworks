<template>
  <CustomAttributes
    v-if="projectPreferences"
    ref="customAttributeRef"
    :object-id="collectingEvent.id"
    :object-type="COLLECTING_EVENT"
    :model="COLLECTING_EVENT"
    :model-preferences="
      projectPreferences.model_predicate_sets[COLLECTING_EVENT]
    "
    @on-update="setAttributes"
  />
</template>

<script setup>
import CustomAttributes from '@/components/custom_attributes/predicates/predicates'
import { COLLECTING_EVENT } from '@/constants'
import { MutationNames } from '../../../../store/mutations/mutations'
import { GetterNames } from '../../../../store/getters/getters.js'
import { ActionNames } from '../../../../store/actions/actions.js'
import { computed, onBeforeUnmount, ref } from 'vue'
import { useStore } from 'vuex'

const store = useStore()
const customAttributeRef = ref()

const collectingEvent = computed({
  get: () => store.getters[GetterNames.GetCollectingEvent],
  set: (value) => store.commit(MutationNames.SetCollectingEvent, value)
})

const projectPreferences = computed(
  () => store.getters[GetterNames.GetProjectPreferences]
)

const unsubscribe = store.subscribeAction({
  after: (action) => {
    if (action.type === ActionNames.SaveCollectingEvent) {
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
  collectingEvent.value.data_attributes_attributes = dataAttributes
}
</script>
