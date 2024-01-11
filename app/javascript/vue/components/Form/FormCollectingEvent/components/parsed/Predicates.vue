<template>
  <predicates-component
    v-if="projectPreferences"
    :object-id="collectingEvent.id"
    object-type="CollectingEvent"
    model="CollectingEvent"
    :model-preferences="projectPreferences.model_predicate_sets.CollectingEvent"
    @on-update="setAttributes"
  />
</template>

<script setup>
import { ref } from 'vue'
import { Project } from '@/routes/endpoints'
import PredicatesComponent from '@/components/custom_attributes/predicates/predicates'

const collectingEvent = defineModel()

const projectPreferences = ref(undefined)

Project.preferences().then((response) => {
  projectPreferences.value = response.body
})

function setAttributes(dataAttributes) {
  collectingEvent.value.data_attributes_attributes = dataAttributes
}
</script>
