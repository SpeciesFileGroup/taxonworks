<template>
  <TableGrid
    :columns="3"
    :column-width="{
      default: 'min-content',
      0: '1fr',
      1: '1fr',
      2: '2fr'
    }"
    gap="1em"
  >
    <PanelDwc />
    <TableGrid
      :columns="1"
      gap="1em"
      :column-width="{
        default: 'min-content',
        0: '1fr'
      }"
    >
      <PanelDepictions />
      <PanelMap />
    </TableGrid>
    <PanelTimeline />
  </TableGrid>
</template>

<script setup>
import PanelDepictions from './PanelDepictions.vue'
import PanelMap from './PanelMap.vue'
import PanelTimeline from './PanelTimeline.vue'
import PanelDwc from './PanelDwc.vue'
import TableGrid from 'components/layout/Table/TableGrid.vue'
</script>
