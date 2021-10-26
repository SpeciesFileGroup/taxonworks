<template>
  <fieldset class="fieldset">
    <legend>Source</legend>
    <smart-selector
      class="full_width"
      model="sources"
      klass="CollectionObject"
      target="CollectionObject"
      pin-section="Sources"
      pin-type="Source"
      label="cached"
      v-model="source"
      @selected="setSource"
    />
    <hr>
    <div
      v-if="source"
      class="field horizontal-left-content middle">
      <span v-html="source.cached"/>
      <button
        type="button"
        class="button circle-button btn-undo button-default"
        @click="setSource(undefined)"/>
    </div>
    <div class="field">
      <input
        type="text"
        class="pages"
        placeholder="Pages"
        v-model="citation.pages"
      >
    </div>
  </fieldset>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { Source } from 'routes/endpoints'
import SmartSelector from 'components/ui/SmartSelector.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])
const source = ref(undefined)
const citation = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

watch(() => props.modelValue.source_id, id => {
  if(id) {
    if (id !== source.value?.id) {
      Source.find(id).then(({ body }) => {
        source.value = body
      })
    }
  } else {
    source.value = undefined
  }
})

const setSource = value => {
  source.value = value
  citation.value.source_id = value?.id
}
</script>
