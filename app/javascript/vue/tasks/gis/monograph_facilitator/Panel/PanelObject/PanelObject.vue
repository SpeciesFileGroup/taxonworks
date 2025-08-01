<template>
  <div class="flex-col">
    <PanelObjectHeader @toggle-list="toggleGroups" />
    <div class="panel-attributes">
      <PanelAttributeGroup
        v-for="group in sortedGroups"
        ref="panels"
        :key="group.determination.id"
        :group="group"
      />
    </div>
  </div>
</template>

<script setup>
import { computed, useTemplateRef } from 'vue'
import { sortGroupsByLastSelectedIndex } from '../../utils/sortGroupsByLastSelectedIndex.js'
import useStore from '../../store/store.js'
import PanelAttributeGroup from './PanelObjectGroup.vue'
import PanelObjectHeader from './PanelObjectHeader.vue'

const store = useStore()

const panelRefs = useTemplateRef('panels')

const sortedGroups = computed(() => {
  const allSelected = []
  const someSelected = []
  const noneSelected = []

  store.groups.forEach((group) => {
    const length = group.list.length
    const count = group.list.filter((item) =>
      store.selectedIds.includes(item.id)
    ).length

    if (count === 0) {
      noneSelected.push(group)
    } else if (length !== count) {
      someSelected.push(group)
    } else {
      allSelected.push(group)
    }
  })

  return [
    ...sortGroupsByLastSelectedIndex(allSelected, store.selectedIds),
    ...sortGroupsByLastSelectedIndex(someSelected, store.selectedIds),
    ...sortGroupsByLastSelectedIndex(noneSelected, store.selectedIds)
  ]
})

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
  min-width: 400px;
  width: 400px;
  font-size: 12px;
}
</style>
