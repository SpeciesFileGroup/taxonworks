<template>
  <div>
    <table class="position-relative">
      <thead>
        <tr>
          <th
            class="position-sticky">
            Selected
          </th>
          <status-filter
            class="position-sticky margin-medium-left"
            v-model="params.status"/>
          <column-filter
            v-for="(item, index) in datasetHeaders"
            :key="index"
            :title="item"
            :disabled="disabled"
            class="position-sticky margin-medium-left"
            v-model="params.filter[index]"
            :field="index"/>
        </tr>
      </thead>
      <tbody>
        <row-component
          v-for="(row, index) in datasetRecords"
          class="contextMenuCells"
          :class="{ 'even': (index % 2 == 0) }"
          :row="row"/>
      </tbody>
    </table>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'

import RowComponent from './row'
import ColumnFilter from './ColumnFilter'
import StatusFilter from './StatusFilter'

export default {
  components: {
    RowComponent,
    ColumnFilter,
    StatusFilter
  },
  props: {
    disabled: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    params: {
      get () {
        return this.$store.getters[GetterNames.GetParamsFilter]
      },
      set (value) {
        this.$store.commit(MutationNames.SetParamsFilter, value)
      }
    },
    datasetHeaders () {
      return this.$store.getters[GetterNames.GetDataset].metadata.core_headers
    },
    datasetRecords () {
      return this.$store.getters[GetterNames.GetDatasetRecords]
    }
  },
  data () {
    return {
      isProcessing: false
    }
  },
  watch: {
    params: {
      handler () {
        this.$store.dispatch(ActionNames.LoadDatasetRecords)
      },
      deep: true
    }
  }
}
</script>

<style scoped>
  th {
    top: 0
  }

  .show-import-process {
    width: 400px;
    position: fixed;
    bottom: 0px;
    height: 100px;
    z-index: 201;
    left: 50%;
    transform: translate(-50%);
  }
</style>
