<template>
  <label>Geographic area</label>
  <SelectedItem
    v-if="store.geographicArea"
    :item="store.geographicArea"
    @unset="store.geographicArea = undefined"
  />
  <Autocomplete
    v-else
    url="/geographic_areas/autocomplete"
    param="term"
    label="label_html"
    autofocus
    placeholder="Search a geographic area"
    clear-after
    :input-attributes="{
      'data-locked': store.settings.lock.collectingEvent
    }"
    @get-item="store.geographicArea = $event"
  />
</template>

<script setup>
import Autocomplete from 'components/ui/Autocomplete.vue'
import SelectedItem from './SelectedItem.vue'
import { useStore } from '../store/useStore'

const store = useStore()
</script>
