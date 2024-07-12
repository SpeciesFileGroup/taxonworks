<template>
  <div>
    <label class="d-block">{{ model }}</label>
    <VAutocomplete
      :url="TYPE_LINKS[model].autocomplete"
      :min="2"
      param="term"
      placeholder="Select an object"
      label="label_html"
      clear-after
      @select="loadObject"
    />
    <SmartSelectorItem
      :item="selected"
      label="object_tag"
      @unset="() => (selected = null)"
    />
  </div>
</template>

<script setup>
import { TYPE_LINKS } from '../constants/types'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import * as endpoints from '@/routes/endpoints'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'

const props = defineProps({
  model: {
    type: String,
    required: true
  }
})

const selected = defineModel({
  type: [Object, null],
  default: undefined
})

function loadObject({ id }) {
  endpoints[props.model].find(id).then(({ body }) => {
    selected.value = body
  })
}
</script>
