<template>
  <div class="confidence_annotator">
    <smart-selector
      class="margin-medium-bottom"
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{ 'type[]': CONFIDENCE_LEVEL }"
      get-url="/controlled_vocabulary_terms/"
      model="confidence_levels"
      button-class="button-submit"
      buttons
      inline
      :klass="TAG"
      :filter="confidenceAlreadyCreated"
      :target="objectType"
      :custom-list="{ all: allList, new: [] }"
      @selected="(item) => createConfidence({ confidence_level_id: item.id })"
    >
      <template #new>
        <NewConfidence @submit="createConfidence" />
      </template>
    </smart-selector>

    <list-items
      :label="['confidence_level', 'object_tag']"
      :list="list"
      @delete="removeItem"
      target-citations="confidences"
      class="list"
    />
  </div>
</template>
<script setup>
import ListItems from '../shared/listItems.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import NewConfidence from './NewConfidence.vue'
import { ControlledVocabularyTerm, Confidence } from '@/routes/endpoints'
import { CONFIDENCE_LEVEL, TAG } from '@/constants'
import { ref } from 'vue'
import { removeFromArray } from '@/helpers'

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['update-count'])

const allList = ref([])
const list = ref([])

function createConfidence(payload) {
  Confidence.create({
    confidence: {
      ...payload,
      confidence_object_id: props.objectId,
      confidence_object_type: props.objectType
    }
  }).then((response) => {
    list.value.push(response.body)
    emit('update-count', list.value.length)
  })
}

function removeItem(item) {
  Confidence.destroy(item.id).then((_) => {
    removeFromArray(list.value, item)
    emit('update-count', list.value.length)
  })
}

function confidenceAlreadyCreated(confidence) {
  return !list.value.some((item) => confidence.id === item.confidence_level_id)
}

Confidence.where({
  confidence_object_id: props.objectId,
  confidence_object_type: props.objectType,
  per: 500
}).then(({ body }) => {
  list.value = body
})

ControlledVocabularyTerm.where({ type: [CONFIDENCE_LEVEL] }).then(
  ({ body }) => {
    allList.value = body
  }
)
</script>
<style lang="scss">
.radial-annotator {
  .confidence_annotator {
    textarea {
      padding-top: 14px;
      padding-bottom: 14px;
      width: 100%;
      height: 100px;
    }
    .vue-autocomplete-input {
      width: 100%;
    }
  }
}
</style>
