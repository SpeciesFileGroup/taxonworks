<template>
  <tr>
    <td>
      <browse-button
        v-if="isImported"
        :row="row"/>
      <import-row
        v-else
        :row="row"/>
    </td>
    <import-row-state :row="row"/>
    <cell-component
      v-for="(data_field, index) in tableHeaders"
      :key="index"
      :cell="row.data_fields[index]"
      :cell-index="index"
      :disabled="isProcessing"
      @update="updateRecord"/>
  </tr>
</template>

<script>

import ImportRowState from './ImportRowState'
import CellComponent from './Cell'
import ImportRow from './ImportRow'
import BrowseButton from './BrowseButton'
import { ActionNames } from '../store/actions/actions'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    CellComponent,
    ImportRowState,
    ImportRow,
    BrowseButton
  },
  props: {
    row: {
      type: Object,
      required: true
    }
  },
  computed: {
    selectedIds: {
      get () {
        return this.$store.getters[GetterNames.GetSelectedRowIds]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSelectedRowIds, value)
      }
    },
    isImported () {
      return this.row.status === 'Imported'
    },
    isProcessing () {
      return this.$store.getters[GetterNames.GetSettings].isProcessing
    },
    tableHeaders () {
      const { metadata: { core_headers: headers } } = this.$store.getters[GetterNames.GetDataset]
      return headers
    }
  },
  methods: {
    updateRecord (data) {
      this.$store.dispatch(ActionNames.UpdateRow, { rowId: this.row.id, data_fields: JSON.stringify(data) })
    }
  }
}
</script>
