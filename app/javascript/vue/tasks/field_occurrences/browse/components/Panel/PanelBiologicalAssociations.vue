<template>
  <PanelContainer title="Biological associations">
    <ListITems
      class="no_bullets"
      :list="store.biologicalAssociations"
      label="object_tag"
      :remove="false"
    />
  </PanelContainer>
</template>

<script setup>
import PanelContainer from './PanelContainer.vue'
import ListITems from '@/components/displayList.vue'
import useBiologicalAssociationsStore from '../../store/biologicalAssociations.js'

const store = useBiologicalAssociationsStore()
</script>
