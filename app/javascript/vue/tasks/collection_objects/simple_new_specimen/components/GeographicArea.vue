<template>
  <fieldset>
    <legend>Geographic area</legend>
    <SmartSelector
      ref="smartSelector"
      model="geographic_areas"
      target="CollectingEvent"
      label="name"
      klass="CollectingEvent"
      @selected="store.geographicArea = $event"
    />
    <SmartSelectorItem
      :item="store.geographicArea"
      label="object_tag"
      @unset="state.geographicArea = undefined"
    />
  </fieldset>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector.vue'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import { useStore } from '../store/useStore'

const store = useStore()
</script>
