<template>
  <div>
    <label class="d-block">{{ title }}</label>
    <VAutocomplete
      :url="TYPE_LINKS[model].autocomplete"
      :min="2"
      param="term"
      placeholder="Select an object"
      label="label_html"
      clear-after
      @select="({ id }) => loadObjectById(id)"
    />
    <SmartSelectorItem
      :item="selected"
      label="object_tag"
      @unset="() => (selected = null)"
    >
      <template #options-left>
        <RadialAnnotator :global-id="selected.global_id" />
        <RadialObject
          v-if="TYPE_LINKS[model].radialObject"
          :global-id="selected.global_id"
        />
        <RadialNavigator :global-id="selected.global_id" />
      </template>
    </SmartSelectorItem>
  </div>
</template>

<script setup>
import { TYPE_LINKS } from '../constants/types'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import * as endpoints from '@/routes/endpoints'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'

const props = defineProps({
  title: {
    type: String,
    required: true
  },

  model: {
    type: String,
    required: true
  }
})

const selected = defineModel({
  type: [Object, null],
  default: undefined
})

function loadObjectById(id) {
  endpoints[props.model].find(id).then(({ body }) => {
    selected.value = body
  })
}

defineExpose({
  loadObjectById
})
</script>
