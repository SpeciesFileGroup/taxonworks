<template>
  <FacetContainer>
    <h3>Citation topics</h3>
    <fieldset>
      <legend>Topics</legend>
      <smart-selector
        :autocomplete-params="{ 'type[]': 'Topic' }"
        model="topics"
        target="Citation"
        klass="Topic"
        autocomplete-url="/controlled_vocabulary_terms/autocomplete"
        get-url="/controlled_vocabulary_terms/"
        :custom-list="topicList"
        @selected="addTopic"
      />
    </fieldset>
    <display-list
      :list="topics"
      label="object_tag"
      :delete-warning="false"
      @delete-index="removeTopic"
    />
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import SmartSelector from 'components/ui/SmartSelector'
import DisplayList from 'components/displayList'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { ControlledVocabularyTerm } from 'routes/endpoints'
import { ref, computed, watch, onBeforeMount } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const topics = ref([])
const topicList = ref([])

watch(params, (newVal, oldVal) => {
  if (!newVal?.topic_id?.length && oldVal?.topic_id?.length) {
    this.topics = []
  }
})

watch(
  topics,
  () => {
    params.value.topic_id = topics.value.map((topic) => topic.id)
  },
  { deep: true }
)

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  ControlledVocabularyTerm.where({ type: ['Topic'] }).then((response) => {
    topicList.value = { all: response.body }
  })

  if (urlParams.topic_id) {
    urlParams.topic_id.forEach((id) => {
      ControlledVocabularyTerm.find(id).then((response) => {
        addTopic(response.body)
      })
    })
  }
})

const addTopic = (topic) => {
  if (!params.value?.topic_id?.includes(topic.id)) {
    topics.value.push(topic)
  }
}

const removeTopic = (index) => {
  topics.value.splice(index, 1)
}
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
