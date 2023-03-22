<template>
  <FacetContainer>
    <h3>Topics</h3>
    <fieldset>
      <legend>Keywords</legend>
      <smart-selector
        autocomplete-url="/controlled_vocabulary_terms/autocomplete"
        :autocomplete-params="{ 'type[]': 'Topic' }"
        get-url="/controlled_vocabulary_terms/"
        model="keywords"
        klass="Topic"
        pin-section="Keywords"
        pin-type="Keyword"
        :target="target"
        :custom-list="allFiltered"
        @selected="addToArray(topics, $event)"
      />
    </fieldset>
    <DisplayList
      v-if="topics.length"
      :list="topics"
      label="name"
      soft-delete
      :warning="false"
      @delete="removeFromArray(topics, $event)"
    />
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import SmartSelector from 'components/ui/SmartSelector'
import DisplayList from 'components/displayList.vue'
import { ControlledVocabularyTerm } from 'routes/endpoints'
import { computed, ref, watch, onBeforeMount } from 'vue'
import { removeFromArray, addToArray } from 'helpers/arrays'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  },

  target: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const topics = ref([])

watch(
  () => props.modelValue.topic_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      topics.value = []
    }
  }
)

watch(
  topics,
  () => {
    params.value.topic_id = topics.value.map((t) => t.id)
  },
  { deep: true }
)

onBeforeMount(() => {
  const topicIds = props.modelValue.topic_id || []

  topicIds.forEach((id) => {
    ControlledVocabularyTerm.find(id).then((response) => {
      addToArray(topics.value, response.body)
    })
  })
})
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
