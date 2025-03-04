<template>
  <TableGrid
    :columns="1"
    gap="1em"
  >
    <SoftValidations
      v-if="false"
      class="column-validation"
    />
    <PanelIdentifier />
    <PanelDepictions />
    <PanelMap />
  </TableGrid>
</template>

<script setup>
import SoftValidations from '@/components/soft_validations/panel.vue'
import PanelIdentifier from './Panel/PanelIdentifier.vue'
import TableGrid from '@/components/layout/Table/TableGrid.vue'
import PanelDepictions from './Panel/PanelDepictions.vue'
import PanelMap from './Panel/PanelMap.vue'
</script>
