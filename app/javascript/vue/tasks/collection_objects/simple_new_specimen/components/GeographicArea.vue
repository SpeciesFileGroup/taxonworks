<template>
  <fieldset>
    <legend>Geographic area</legend>
    <SmartSelector
      v-model="store.geographicArea"
      ref="smartSelector"
      model="geographic_areas"
      target="CollectingEvent"
      label="name"
      klass="CollectingEvent"
    />
    <hr v-if="store.geographicArea">
    <SmartSelectorItem
      :item="store.geographicArea"
      label="name"
      @unset="store.geographicArea = undefined"
    />
  </fieldset>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector.vue'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import { useStore } from '../store/useStore'

const store = useStore()
</script>
