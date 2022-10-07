<template>
  <TableGrid :columns="1">
    <SoftValidations
      class="column-validation"
      :validations="store.getters[GetterNames.GetSoftValidations]"
    />
    <PanelIdentifier />
  </TableGrid>
</template>

<script setup>
import { useStore } from 'vuex'
import { GetterNames } from '../store/getters/getters'
import SoftValidations from 'components/soft_validations/panel.vue'
import PanelIdentifier from './Panel/PanelIdentifier.vue'
import TableGrid from 'components/layout/Table/TableGrid.vue'

const store = useStore()
</script>
