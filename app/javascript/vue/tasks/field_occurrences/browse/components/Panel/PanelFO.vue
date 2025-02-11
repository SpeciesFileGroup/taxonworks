<template>
  <TableGrid
    :columns="1"
    gap="1em"
  >
    <TableGrid
      gap="1em"
      :columns="1"
      :column-width="{
        default: '1fr'
      }"
    >
      <PanelBiocurations />
    </TableGrid>
    <PanelDeterminations />
    <PanelBiologicalAssociations />
  </TableGrid>
</template>

<script setup>
import PanelDeterminations from './PanelDeterminations.vue'
import PanelBiocurations from './PanelBiocurations.vue'
import PanelBiologicalAssociations from './PanelBiologicalAssociations.vue'
import TableGrid from '@/components/layout/Table/TableGrid.vue'
</script>
