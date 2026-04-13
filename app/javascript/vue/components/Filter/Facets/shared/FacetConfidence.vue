<template>
  <FacetContainer>
    <h3>Confidences</h3>

    <SmartSelector
      ref="smartSelectorRef"
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{ 'type[]': CONFIDENCE_LEVEL }"
      get-url="/controlled_vocabulary_terms/"
      model="confidence_levels"
      klass="Confidence"
      pin-section="ConfidenceLevels"
      :pin-type="CONFIDENCE_LEVEL"
      :add-tabs="['all']"
      :target="target"
      @selected="addConfidence"
    >
      <template #all>
        <VModal @close="smartSelectorRef.setTab('quick')">
          <template #header>
            <h3>Confidence levels - all</h3>
          </template>
          <template #body>
            <VBtn
              v-for="item in allFiltered"
              :key="item.id"
              class="margin-small-bottom margin-small-right"
              color="primary"
              pill
              @click="addConfidence(item)"
            >
              {{ item.name }}
            </VBtn>
          </template>
        </VModal>
      </template>
    </SmartSelector>
    <table
      v-if="confidences.length"
      class="vue-table"
    >
      <thead>
        <tr>
          <th>Name</th>
          <th />
          <th />
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody"
      >
        <template
          v-for="(item, index) in confidences"
          :key="index"
        >
          <RowItem
            class="list-complete-item"
            :item="item"
            label="object_tag"
            :options="{
              With: true,
              Without: false
            }"
            v-model="item.withConfidence"
            @remove="() => removeConfidence(index)"
          />
        </template>
      </transition-group>
    </table>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import SmartSelector from '@/components/ui/SmartSelector'
import RowItem from './RowItem'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import { computed, ref, watch, onBeforeMount } from 'vue'
import { CONFIDENCE_LEVEL } from '@/constants'

const props = defineProps({
  target: {
    type: String,
    required: true
  }
})

const smartSelectorRef = ref(null)

const params = defineModel({
  type: Object,
  required: true
})

const allFiltered = computed(() => {
  const confidenceIds = confidences.value.map(({ id }) => id)

  return allList.value.filter((item) => !confidenceIds.includes(item.id))
})

const confidences = ref([])
const allList = ref([])

watch(
  [
    () => props.modelValue.confidence_level_id,
    () => props.modelValue.without_confidence_level_id
  ],
  () => {
    if (
      !props.modelValue.confidence_level_id?.length &&
      !props.modelValue.without_confidence_level_id?.length &&
      confidences.value.length
    ) {
      confidences.value = []
    }
  }
)
watch(
  confidences,
  () => {
    params.value.confidence_level_id = confidences.value
      .filter((c) => c.withConfidence)
      .map((c) => c.id)
    params.value.without_confidence_level_id = confidences.value
      .filter((c) => !c.withConfidence)
      .map((c) => c.id)
  },
  { deep: true }
)

onBeforeMount(() => {
  const { confidence_level_id = [], without_confidence_level_id = [] } =
    props.modelValue

  confidence_level_id.forEach((id) => {
    ControlledVocabularyTerm.find(id).then((response) => {
      addConfidence(response.body, true)
    })
  })

  without_confidence_level_id.forEach((id) => {
    ControlledVocabularyTerm.find(id).then((response) => {
      addConfidence(response.body, false)
    })
  })

  ControlledVocabularyTerm.where({ type: [CONFIDENCE_LEVEL] }).then(
    ({ body }) => {
      allList.value = body
    }
  )
})

function addConfidence(confidence, withConfidence = true) {
  if (!confidences.value.find((item) => item.id === confidence.id)) {
    confidences.value.push({ ...confidence, withConfidence })
  }
}

function removeConfidence(index) {
  confidences.value.splice(index, 1)
}
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
