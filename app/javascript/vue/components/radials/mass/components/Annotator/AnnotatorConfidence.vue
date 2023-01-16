<template>
  <div class="confidence_annotator">
    <smart-selector
      class="margin-medium-bottom"
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{'type[]' : 'ConfidenceLevel'}"
      get-url="/controlled_vocabulary_terms/"
      model="confidence_levels"
      button-class="button-submit"
      buttons
      inline
      klass="Tag"
      :target="objectType"
      :custom-list="{ all: allList }"
      @selected="createConfidence"
    />
  </div>
</template>

<script setup>
import { ref, onBeforeMount } from 'vue'
import { ControlledVocabularyTerm, Confidence } from 'routes/endpoints'
import SmartSelector from 'components/ui/SmartSelector.vue'

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  objectType: {
    type: String,
    required: true
  }
})

const allList = ref([])

onBeforeMount(() => {
  ControlledVocabularyTerm.where({ type: ['ConfidenceLevel'] }).then(({ body }) => {
    allList.value = body
  })
})

function createConfidence (confidence) {
  const promises = props.ids.map(id => {
    const payload = {
      confidence_level_id: confidence.id,
      confidence_object_id: id,
      confidence_object_type: props.objectType
    }

    return Confidence.create({ confidence: payload })
  })

  Promise.all(promises).then(_ => {
    TW.workbench.alert.create('Note item(s) were successfully created', 'notice')
  })
}

</script>
