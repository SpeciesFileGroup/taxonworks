<template>
  <div class="union-inputs">
    <fieldset class="shape-input">
      <legend>Add Geographic Areas to this Gazetteer</legend>
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
        @get-item="(item) => addShape(item, GZ_COMBINE_GA)"
      />
    </fieldset>

    <fieldset class="shape-input">
      <legend>Add other Gazetteers to this Gazetteer</legend>
      <VAutocomplete
        :disabled="inputsDisabled"
        min="2"
        placeholder="Select a Gazetteer"
        label="label_html"
        display="label"
        clear-after
        param="term"
        url="/gazetteers/autocomplete"
        @get-item="(item) => addShape(item, GZ_COMBINE_GZ)"
      />
    </fieldset>
  </div>
</template>

<script setup>
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import {
  GZ_COMBINE_GA,
  GZ_COMBINE_GZ
} from '@/constants/index.js'

const props = defineProps({
  inputsDisabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['newShape'])

function addShape(item, type) {
  if (type == GZ_COMBINE_GA && item.label_html.includes('without shape')) {
    TW.workbench.alert.create('Only GAs with shape can be added.', 'error')
    return
  }
  emit('newShape', item, type)
}
</script>

<style lang="scss" scoped>
.shape-input {
  width: 400px;
  padding: 1.5em;
  margin-bottom: 1.5em;
  margin-top: 1.5em;
  margin-right: 1em;
}

.union-inputs {
  display: flex;
  flex-wrap: wrap;
}
</style>