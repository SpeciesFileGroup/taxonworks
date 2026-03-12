<template>
  <VAutocomplete
    ref="autocomplete"
    url="/sources/autocomplete"
    param="term"
    placeholder="Search a source..."
    label="label_html"
    clear-after
    autofocus
    @get-item="({ id }) => store.loadSource(id)"
  />
</template>

<script setup>
import { ref } from 'vue'
import { useSourceStore } from '../store'
import VAutocomplete from '@/components/ui/Autocomplete.vue'

const store = useSourceStore()
const autocomplete = ref(null)

function focusSearch() {
  autocomplete.value?.setFocus()
}

defineExpose({ focusSearch })
</script>
