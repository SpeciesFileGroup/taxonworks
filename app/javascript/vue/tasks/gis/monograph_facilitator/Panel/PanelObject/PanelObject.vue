<template>
  <div class="panel-attributes">
    <PanelObjectHeader />
    <PanelAttributeGroup
      v-for="group in store.groups"
      :key="group.determination.id"
      :group="group"
    />
  </div>
</template>

<script setup>
import useStore from '../../store/store.js'
import PanelAttributeGroup from './PanelObjectGroup.vue'
import PanelObjectHeader from './PanelObjectHeader.vue'

const store = useStore()
</script>

<style scoped>
.panel-attributes {
  max-height: 100%;
  overflow-y: auto;
  overflow-x: hidden;
  min-width: 400px;
  width: 400px;
  font-size: 12px;
}
</style>
