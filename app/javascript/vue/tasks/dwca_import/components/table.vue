<template>
  <div>
    <virtual-scroller
      :items="list"
      :item-height="40"
      class="vscroll"
      ref="table"
      @update="getPages">
      <template slot-scope="{ items }">
        <spinner-component v-if="isLoading"/>
        <table
          class="table">
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
            <template v-for="(item, index) in items">
              <row-component
                v-if="item"
                :key="index"
                class="contextMenuCells"
                :class="{ 'even': (index % 2 == 0) }"
                :row="item"/>
              <tr
                v-else
                class="row-empty"
                :key="index">
                <td colspan="100"/>
              </tr>
            </template>
          </tbody>
        </table>
      </template>
    </virtual-scroller>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import VirtualScroller from './VirtualScroller.vue'
import SpinnerComponent from 'components/spinner'

import RowComponent from './row'
import ColumnFilter from './ColumnFilter'
import StatusFilter from './StatusFilter'

export default {
  components: {
    VirtualScroller,
    RowComponent,
    ColumnFilter,
    StatusFilter,
    SpinnerComponent
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
      const metadata = this.$store.getters[GetterNames.GetDataset].metadata
      return metadata ? metadata.core_headers : []
    },
    datasetRecords () {
      return this.$store.getters[GetterNames.GetDatasetRecords]
    },
    list () {
      return [].concat(...this.datasetRecords.map(page => page.rows ? page.rows : new Array(page.count)).slice(1))
    }
  },
  data () {
    return {
      isLoading: false
    }
  },
  watch: {
    params: {
      handler () {
        this.$refs.table.$el.scrollTop = 0
        this.isLoading = true
        this.$store.dispatch(ActionNames.LoadDatasetRecords).then(() => {
          this.isLoading = false
        })
      },
      deep: true
    }
  },
  methods: {
    loadPage (pages) {
      pages.forEach(page => {
        this.$store.dispatch(ActionNames.LoadDatasetRecords, page)
      })
    },
    getPages (indexes) {
      const pages = [Math.floor(indexes.endIndex / this.params.per), Math.ceil(indexes.endIndex / this.params.per)].map(page => page === 0 ? 1 : page)
      this.loadPage(pages)
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
  .vscroll {
    height: calc(100vh - 230px);
    overflow: auto;
    overflow-anchor: none;
    z-index: 500000;
  }
  .row-empty {
    background: linear-gradient(transparent,transparent 20%,hsla(0,0%,50.2%,0.03) 0,hsla(0,0%,50.2%,0.08) 50%,hsla(0,0%,50.2%,0.03) 80%,transparent 0,transparent);
    background-size:100% 40px
  }
</style>
