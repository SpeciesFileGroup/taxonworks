<template>
  <FacetContainer>
    <h3>Topics</h3>

    <SmartSelector
      ref="smartSelectorRef"
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{ 'type[]': TOPIC }"
      get-url="/controlled_vocabulary_terms/"
      model="keywords"
      :klass="TOPIC"
      pin-section="Topics"
      :pin-type="TOPIC"
      :add-tabs="['all']"
      :target="target"
      @selected="addToArray(topics, $event)"
    >
      <template #all>
        <VModal
          :container-style="{ width: '500px' }"
          @close="smartSelectorRef.setTab('quick')"
        >
          <template #header>
            <h3>Topics - all</h3>
          </template>
          <template #body>
            <div class="flex-wrap-row gap-small">
              <VBtn
                v-for="item in allTopics"
                :key="item.id"
                color="primary"
                pill
                v-html="item.object_tag"
                @click="() => addToArray(topics, item)"
              />
            </div>
          </template>
        </VModal>
      </template>
    </SmartSelector>

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
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import SmartSelector from '@/components/ui/SmartSelector'
import DisplayList from '@/components/displayList.vue'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import { computed, ref, watch, onBeforeMount, useTemplateRef } from 'vue'
import { removeFromArray, addToArray } from '@/helpers/arrays'
import { TOPIC } from '@/constants'

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

const smartSelectorRef = useTemplateRef('smartSelectorRef')
const topics = ref([])
const allTopics = ref([])

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

  ControlledVocabularyTerm.where({ type: [TOPIC] }).then(({ body }) => {
    allTopics.value = body
  })
})
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
