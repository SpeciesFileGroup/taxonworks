<template>
  <TableGrid
    :columns="1"
    gap="1em"
  >
    <PanelBuffered />
    <PanelIdentifier :type="COLLECTION_OBJECT" />
    <PanelBiocurations />
    <SoftValidations
      class="column-validation"
      :validations="store.getters[GetterNames.GetSoftValidationFor](COLLECTION_OBJECT)"
    />
  </TableGrid>
</template>

<script setup>
import PanelBuffered from './PanelBuffered/PanelBuffered.vue'
import PanelIdentifier from './PanelIdentifier.vue'
import PanelBiocurations from './PanelBiocurations.vue'
import TableGrid from 'components/layout/Table/TableGrid.vue'
import SoftValidations from 'components/soft_validations/panel.vue'
import { GetterNames } from '../../store/getters/getters'
import { COLLECTION_OBJECT } from 'constants/index.js'
import { useStore } from 'vuex'

const store = useStore()
</script>
