<template>
  <div class="flex-col">
    <PanelObjectHeader @toggle-list="toggleGroups" />
    <div class="panel-attributes">
      <PanelAttributeGroup
        v-for="group in store.sortedGroups"
        ref="panels"
        :key="group.uuid"
        :group="group"
      />
    </div>
  </div>
</template>

<script setup>
import { useTemplateRef } from 'vue'
import useStore from '../../store/store.js'
import PanelAttributeGroup from './PanelObjectGroup.vue'
import PanelObjectHeader from './PanelObjectHeader.vue'

const store = useStore()

const panelRefs = useTemplateRef('panels')

function toggleGroups(value) {
  if (value) {
    panelRefs.value.forEach((p) => p.showList())
  } else {
    panelRefs.value.forEach((p) => p.hideList())
  }
}
</script>

<style scoped>
.panel-attributes {
  max-height: 100%;
  overflow-y: auto;
  overflow-x: hidden;
  min-width: 500px;
  width: 500px;
  font-size: 12px;
}
</style>
