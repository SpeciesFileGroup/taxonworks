<template>
  <fieldset class="shape-input">
    <legend>Add Geographic Areas to your Gazetteer</legend>
    <VAutocomplete
      :disabled="inputsDisabled"
      min="2"
      placeholder="Select a Geographic Area"
      label="label_html"
      display="label"
      clear-after
      param="term"
      :addParams="{ mark: false }"
      url="/geographic_areas/autocomplete"
      @get-item="(item) => addShape(item)"
    />
  </fieldset>
</template>

<script setup>
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import {
  GZ_UNION
} from '@/constants/index.js'

const props = defineProps({
  inputsDisabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['newShape'])

function addShape(item) {
  if (item.label_html.includes('without shape')) {
    TW.workbench.alert.create('Only GAs with shape can be added.', 'error')
    return
  }
  // TODO can we reject if choice doesn't have a shape?
  emit('newShape', item, GZ_UNION)
}
</script>

<style lang="scss" scoped>
.shape-input {
  width: 400px;
  padding: 1.5em;
  margin-bottom: 1.5em;
  margin-top: 1.5em;
}
</style>