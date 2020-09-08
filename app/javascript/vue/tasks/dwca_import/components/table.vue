<template>
  <div>
    <virtual-scroller
      :pages="datasetRecords"
      :item-height="43"
      @currentPages="loadPage">
      <template slot="header">
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
      </template>
      <template v-slot="{ item }">
        <row-component
          class="contextMenuCells"
          :class="{ 'even': (item.index % 2 == 0) }"
          :row="item.row"/>
      </template>
    </virtual-scroller>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import VirtualScroller from './VirtualScroller.vue'

import RowComponent from './row'
import ColumnFilter from './ColumnFilter'
import StatusFilter from './StatusFilter'

export default {
  components: {
    VirtualScroller,
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
  },
  methods: {
    loadPage (pages) {
      pages.forEach(page => {
        this.$store.dispatch(ActionNames.LoadDatasetRecords, page)
      })
    }
  }
}
</script>

<style scoped>
  th {
    top: 0;
    z-index: 2
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
