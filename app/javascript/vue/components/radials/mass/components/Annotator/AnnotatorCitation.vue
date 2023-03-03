<template>
  <div class="confidence_annotator">
    <FormCitation
      :target="objectType"
      v-model="citation"
      :submit-button="{
        label: 'Create',
        color: 'create'
      }"
      @submit="createCitation"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Citation } from 'routes/endpoints'
import FormCitation from 'components/Form/FormCitation.vue'

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

const emit = defineEmits(['create'])

const citation = ref({})
const topics = ref([])

function createCitation() {
  Citation.createBatch({
    citation_object_type: props.objectType,
    source_id: citation.value.source_id,
    pages: citation.value.pages,
    citation_object_id: props.ids
  }).then((response) => {
    TW.workbench.alert.create('Citation(s) were successfully created', 'notice')
    emit('create', response.body)
  })
}
</script>
