<template>
  <tr>
    <td>
      <browse-button
        v-if="isImported"
        :row="row"
      />
      <import-row
        v-else
        :row="row"
      />
    </td>
    <import-row-state :row="row" />
    <template
      v-for="(data_field, index) in tableHeaders"
      :key="index"
    >
      <cell-component
        v-if="settings.ignoredColumns || !isIgnored(index)"
        :class="isIgnored(index) && 'cell-ignore'"
        :cell="row.data_fields[index]"
        :cell-index="index"
        :disabled="isProcessing || isImported"
        @update="updateRecord"
      />
    </template>
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
      get() {
        return this.$store.getters[GetterNames.GetSelectedRowIds]
      },
      set(value) {
        this.$store.commit(MutationNames.SetSelectedRowIds, value)
      }
    },
    settings() {
      return this.$store.getters[GetterNames.GetSettings]
    },
    dataset() {
      return this.$store.getters[GetterNames.GetDataset]
    },
    isImported() {
      return this.row.status === 'Imported'
    },
    isProcessing() {
      return this.$store.getters[GetterNames.GetSettings].isProcessing
    },
    tableHeaders() {
      const {
        metadata: { core_headers: headers }
      } = this.$store.getters[GetterNames.GetDataset]
      return headers
    }
  },
  methods: {
    updateRecord(data) {
      this.$store.dispatch(ActionNames.UpdateRow, {
        rowId: this.row.id,
        data_fields: JSON.stringify(data)
      })
    },

    isIgnored(index) {
      return !this.dataset.metadata?.core_records_mapped_fields?.includes(index)
    }
  }
}
</script>
