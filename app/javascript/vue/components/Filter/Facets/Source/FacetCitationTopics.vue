<template>
  <FacetContainer>
    <h3>Citation topics</h3>
    <fieldset>
      <legend>Topics</legend>
      <SmartSelector
        ref="smartSelector"
        :autocomplete-params="{ 'type[]': 'Topic' }"
        model="topics"
        target="Citation"
        klass="Topic"
        autocomplete-url="/controlled_vocabulary_terms/autocomplete"
        get-url="/controlled_vocabulary_terms/"
        :add-tabs="['all']"
        @selected="addTopic"
      >
        <template #all>
          <VModal @close="smartSelectorRef.setTab('quick')">
            <template #header>
              <h3>Topics - all</h3>
            </template>
            <template #body>
              <div class="flex-wrap-row gap-small">
                <VBtn
                  v-for="item in allFiltered"
                  :key="item.id"
                  color="primary"
                  pill
                  @click="addTopic(item)"
                >
                  {{ item.name }}
                </VBtn>
              </div>
            </template>
          </VModal>
        </template>
      </SmartSelector>
    </fieldset>
    <DisplayList
      :list="topics"
      label="object_tag"
      :delete-warning="false"
      soft-delete
      @delete-index="removeTopic"
    />
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import SmartSelector from '@/components/ui/SmartSelector'
import DisplayList from '@/components/displayList'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { URLParamsToJSON } from '@/helpers/url/parse.js'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import { ref, computed, watch, onBeforeMount, useTemplateRef } from 'vue'

const params = defineModel({
  type: Object,
  required: true
})

const smartSelectorRef = useTemplateRef('smartSelector')
const topics = ref([])
const allTopics = ref([])

const allFiltered = computed(() => {
  const topicIds = topics.value.map(({ id }) => id)

  return allTopics.value.filter((item) => !topicIds.includes(item.id))
})

watch(
  () => params.value.topic_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      topics.value = []
    }
  }
)

watch(
  topics,
  () => {
    params.value.topic_id = topics.value.map((topic) => topic.id)
  },
  { deep: true }
)

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  ControlledVocabularyTerm.where({ type: ['Topic'] }).then(({ body }) => {
    allTopics.value = body
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
