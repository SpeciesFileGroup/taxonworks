<template>
  <fieldset class="fieldset">
    <legend>Source</legend>
    <div class="horizontal-left-content align-start separate-bottom">
      <smart-selector
        class="full_width"
        model="sources"
        klass="CollectionObject"
        target="CollectionObject"
        pin-section="Sources"
        pin-type="Source"
        label="cached"
        v-model="source"
      />
      <v-lock
        class="margin-small-left"
        v-model="lockCOs"/>
    </div>
    <div
      v-if="source"
      class="field horizontal-left-content middle">
      <span v-html="source.cached"/>
      <button
        type="button"
        class="button circle-button btn-undo button-default"
        @click="source = undefined"/>
    </div>
    <div class="field">
      <input
        type="text"
        class="pages"
        placeholder="Pages"
        v-model="pages"
      >
      <label>
        <input
          v-model="is_original"
          type="checkbox">
        Is original
      </label>
    </div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="saveCitation"
      :disabled="!source">
      Add
    </button>
  </fieldset>
</template>

<script setup>
import { reactive } from 'vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import makeCitationObject from 'factory/Citation.js'
import { COLLECTION_OBJECT } from 'constants/index.js'

const emit = defineEmits(['onAdd'])
const citation = reactive({
  source: undefined,
  pages: undefined,
  is_original: undefined
})

const saveCitation = () => {
  emit('onAdd', {
    ...makeCitationObject(COLLECTION_OBJECT),
    citation_source_body: citation.source.cached,
    pages: citation.pages,
    source_id: citation.source.id,
    is_original: citation.is_original
  })

  citation.source = undefined
  citation.is_original = undefined
  citation.pages = undefined
}
</script>
