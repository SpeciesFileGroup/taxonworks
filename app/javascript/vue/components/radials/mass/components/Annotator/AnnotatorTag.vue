<template>
  <div class="tag_annotator">
    <div class="horizontal-right-content">
      <a
        target="_blank"
        :href="RouteNames.ManageControlledVocabularyTask"
      >
        New keyword
      </a>
    </div>
    <smart-selector
      class="margin-medium-bottom"
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{ 'type[]': 'Keyword' }"
      get-url="/controlled_vocabulary_terms/"
      model="keywords"
      buttons
      inline
      klass="Tag"
      :target="objectType"
      :custom-list="{ all: allList }"
      @selected="createWithId"
    />
  </div>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector.vue'
import { ControlledVocabularyTerm, Tag } from 'routes/endpoints'
import { RouteNames } from 'routes/routes'
import { ref, onBeforeMount } from 'vue'

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

function createWithId({ id }) {
  Tag.createBatch({
    object_type: props.objectType,
    keyword_id: id,
    object_id: props.ids
  }).then(() => {
    TW.workbench.alert.create('Tag item(s) were successfully created', 'notice')
  })
}

onBeforeMount(() => {
  ControlledVocabularyTerm.where({ type: ['Keyword'] }).then(({ body }) => {
    allList.value = body
  })
})
</script>
