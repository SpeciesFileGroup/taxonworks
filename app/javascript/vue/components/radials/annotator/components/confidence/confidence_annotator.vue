<template>
  <div class="confidence_annotator">
    <SmartSelector
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
      :custom-list="{ all: allList }"
      @selected="(item) => createConfidence({ confidence_level_id: item.id })"
    >
      <template #tabs-right>
        <a
          :href="`${RouteNames.ManageControlledVocabularyTask}?type=${CONFIDENCE_LEVEL}`"
          >New</a
        >
      </template>
    </SmartSelector>

    <ListItems
      :label="['confidence_level', 'object_tag']"
      :list="list"
      @delete="removeItem"
      target-citations="confidences"
      class="list"
    />
  </div>
</template>
<script setup>
import { useSlice } from '@/components/radials/composables'
import { ControlledVocabularyTerm, Confidence } from '@/routes/endpoints'
import { CONFIDENCE_LEVEL, TAG } from '@/constants'
import { ref } from 'vue'
import { RouteNames } from '@/routes/routes'
import ListItems from '../shared/listItems.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  },

  radialEmit: {
    type: Object,
    required: true
  }
})

const { list, addToList, removeFromList } = useSlice({
  radialEmit: props.radialEmit
})

const allList = ref([])

function createConfidence(payload) {
  Confidence.create({
    confidence: {
      ...payload,
      confidence_object_id: props.objectId,
      confidence_object_type: props.objectType
    }
  }).then(({ body }) => {
    addToList(body)
  })
}

function removeItem(item) {
  Confidence.destroy(item.id).then((_) => {
    removeFromList(item)
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
