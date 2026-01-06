<template>
  <VAutocomplete
    url="/sources/autocomplete"
    param="term"
    placeholder="Search a source..."
    label="label_html"
    clear-after
    @get-item="({ id }) => store.loadSource(id)"
  />
</template>

<script setup>
import { useSourceStore } from '../store'
import VAutocomplete from '@/components/ui/Autocomplete.vue'

const store = useSourceStore()
</script>
