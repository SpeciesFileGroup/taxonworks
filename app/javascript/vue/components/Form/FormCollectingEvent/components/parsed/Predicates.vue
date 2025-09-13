<template>
  <CustomAttributes
    v-if="projectPreferences"
    ref="customAttributes"
    :object-id="collectingEvent.id"
    :object-type="COLLECTING_EVENT"
    :model="COLLECTING_EVENT"
    :model-preferences="projectPreferences.model_predicate_sets.CollectingEvent"
    @on-update="setAttributes"
  />
</template>

<script setup>
import { ref, useTemplateRef } from 'vue'
import { Project } from '@/routes/endpoints'
import { COLLECTING_EVENT } from '@/constants'
import useStore from '../../store/collectingEvent.js'
import CustomAttributes from '@/components/custom_attributes/predicates/predicates'

const collectingEvent = defineModel()

const customAttributes = useTemplateRef('customAttributes')

const store = useStore()
const projectPreferences = ref(undefined)

Project.preferences().then(({ body }) => {
  projectPreferences.value = body
})

function setAttributes(dataAttributes) {
  collectingEvent.value.data_attributes_attributes = dataAttributes
  collectingEvent.value.isUnsaved = true
}

store.$onAction(({ name, after }) => {
  after(() => {
    if (name === 'save') {
      customAttributes.value.loadDataAttributes()
    }
  })
})
</script>
