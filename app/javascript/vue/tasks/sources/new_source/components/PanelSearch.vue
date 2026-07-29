<template>
  <AutocompletePopover
    ref="autocomplete"
    url="/sources/autocomplete"
    param="term"
    placeholder="Search a source..."
    label="label_html"
    clear-after
    medium
    autofocus
    @select="({ id }) => store.loadSource(id)"
  />
</template>

<script setup>
import { ref } from 'vue'
import { useSourceStore } from '../store'
import AutocompletePopover from '@/components/ui/Autocomplete/AutocompletePopover.vue'

const store = useSourceStore()
const autocomplete = ref(null)

function focusSearch() {
  autocomplete.value?.open()
}

defineExpose({ focusSearch })
</script>
