<template>
  <TableGrid
    :columns="1"
    gap="1em"
  >
    <SoftValidations
      class="column-validation"
      :validations="store.getters[GetterNames.GetSoftValidations]"
    />
    <PanelIdentifier />
    <PanelDepictions />
    <PanelMap />
  </TableGrid>
</template>

<script setup>
import { useStore } from 'vuex'
import { GetterNames } from '../store/getters/getters'
import SoftValidations from 'components/soft_validations/panel.vue'
import PanelIdentifier from './Panel/PanelIdentifier.vue'
import TableGrid from 'components/layout/Table/TableGrid.vue'
import PanelDepictions from './Panel/PanelDepictions.vue'
import PanelMap from './Panel/PanelMap.vue'

const store = useStore()
</script>
