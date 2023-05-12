<template>
  <TableGrid
    :columns="1"
    gap="1em"
  >
    <PanelBuffered />
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
    <PanelDisposition />
    <PanelBiologicalAssociations />
    <PanelTypeMaterial />
  </TableGrid>
</template>

<script setup>
import PanelBuffered from './PanelBuffered/PanelBuffered.vue'
import PanelDeterminations from './PanelDeterminations.vue'
import PanelBiocurations from './PanelBiocurations.vue'
import PanelBiologicalAssociations from './PanelBiologicalAssociations.vue'
import PanelTypeMaterial from './PanelTypeMaterial.vue'
import PanelDisposition from './PanelDisposition.vue'
import TableGrid from 'components/layout/Table/TableGrid.vue'
</script>
