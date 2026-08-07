<template>
  <PanelContainer title="Darwin core">
    <TableGbifference
      v-if="ocurrenceId"
      class="full_width"
      :source="{ dwcObject }"
    />
    <TableAttributes
      v-else
      :items="dwcObject"
    />
  </PanelContainer>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import PanelContainer from './PanelContainer.vue'
import TableAttributes from '../Table/TableAttributes.vue'
import TableGbifference from '@/components/ui/Table/TableGbifference.vue'

const store = useStore()
const dwcObject = computed(() => store.getters[GetterNames.GetDwc])
const ocurrenceId = computed(() => dwcObject.value.occurrenceID)
</script>

<style scoped lang="scss">
:deep(.table-gbifference) {
  table {
    box-shadow: none;
  }

  tr {
    border-bottom: 1px solid #eaeaea;
  }

  th {
    text-transform: capitalize;
    border-bottom: 2px solid #eaeaea;
  }
  .cell-value {
    font-weight: 500;
    word-break: break-all;
  }

  .cell-head {
    text-transform: uppercase;
  }
}
</style>
