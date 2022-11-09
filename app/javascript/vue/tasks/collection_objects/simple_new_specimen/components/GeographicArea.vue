<template>
  <div>
    <SmartSelector
      ref="smartSelector"
      model="geographic_areas"
      target="CollectingEvent"
      label="name"
      klass="CollectingEvent"
      @selected="selectGeographicArea"
    />
    <SmartSelectorItem
      :item="geographicArea"
      label="object_tag"
      @unset="state.geographicArea = undefined"
    />
  </div>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector.vue'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
</script>
