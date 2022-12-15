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
import {
  PRIORITIZE_ATTRIBUTES,
  HIDE_ATTRIBUTES
} from '../../constants/darwinCore.js'
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import PanelContainer from './PanelContainer.vue'
import TableAttributes from '../Table/TableAttributes.vue'
import TableGbifference from 'components/ui/Table/TableGbifference.vue'

const store = useStore()
const dwcItems = computed(() => store.getters[GetterNames.GetDwc])

const dwcObject = computed(() => {
  const entries = Object.entries(dwcItems.value)
  const filteredList = entries.filter(([property, _]) => !HIDE_ATTRIBUTES.includes(property))

  filteredList.sort((a, b) => {
    const index1 = PRIORITIZE_ATTRIBUTES.indexOf(a[0])
    const index2 = PRIORITIZE_ATTRIBUTES.indexOf(b[0])

    return (index1 > -1 ? index1 : Infinity) - (index2 > -1 ? index2 : Infinity)
  })

  return Object.fromEntries(filteredList)
})

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
