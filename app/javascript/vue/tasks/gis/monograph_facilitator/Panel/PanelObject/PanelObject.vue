<template>
  <div class="panel-attributes">
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

const store = useStore()
</script>

<style scoped>
.panel-attributes {
  max-height: 100%;
  overflow-y: auto;
  overflow-x: hidden;
  max-width: 400px;
  width: 400px;
}
</style>
