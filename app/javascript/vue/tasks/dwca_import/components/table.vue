<template>
  <div>
    <virtual-pagination-component/>
    <virtual-scroller
      :items="list"
      :item-height="43"
      class="dwca-vscroll"
      ref="table"
      @update="getPages">
      <template slot-scope="{ items }">
        <spinner-component
          legend="Updating records..."
          v-if="isSaving"/>
        <spinner-component v-if="isLoading"/>
        <table
          class="dwca-table">
          <thead>
            <tr>
              <th
                class="position-sticky">
                Options
              </th>
              <status-filter
                class="position-sticky margin-medium-left"
                v-model="params.status"/>
              <column-filter
                v-for="(item, index) in datasetHeaders"
                :key="index"
                :title="item"
                :disabled="disabled"
                :column-index="index"
                @replace="replaceField"
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
                :row="item"/>
              <tr
                v-else
                class="row-empty contextMenuCells"
                :key="index">
                <td style="height: 40px" colspan="100">
                  <div class="dwc-table-cell"/>
                </td>
              </tr>
            </template>
          </tbody>
        </table>
      </template>
    </virtual-scroller>
    <confirmation-modal ref="confirmation"/>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import { UpdateColumnField } from '../request/resources'
import VirtualScroller from './VirtualScroller.vue'
import SpinnerComponent from 'components/spinner'

import RowComponent from './row'
import ColumnFilter from './ColumnFilter'
import StatusFilter from './StatusFilter'
import VirtualPaginationComponent from './VirtualPagination'
import ConfirmationModal from 'components/ConfirmationModal'

export default {
  components: {
    ConfirmationModal,
    VirtualScroller,
    RowComponent,
    ColumnFilter,
    StatusFilter,
    SpinnerComponent,
    VirtualPaginationComponent
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
      return [].concat(...this.datasetRecords.map(page => page.rows ? page.rows : new Array(page.count)))
    },
    currentVirtualPage () {
      return this.$store.getters[GetterNames.GetCurrentVirtualPage]
    },
    importId () {
      return this.$store.getters[GetterNames.GetDataset].id
    }
  },
  data () {
    return {
      isLoading: false,
      isSaving: false
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
    },
    currentVirtualPage () {
      this.$refs.table.$el.scrollTop = 0
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
    },
    async replaceField ({ columnIndex, replaceValue, currentValue }) {
      const ok = await this.$refs.confirmation.show({
        title: this.datasetHeaders[columnIndex],
        message: `<i>${currentValue}</i> will be replaced with <i>${replaceValue}</i> in ${this.datasetRecords.length} records.`,
        typeButton: 'submit'
      })
      if (ok) {
        this.isSaving = true
        UpdateColumnField(this.importId, Object.assign({}, {
          field: columnIndex,
          value: replaceValue
        }, this.params)).then(() => {
          this.$set(this.params.filter, columnIndex, replaceValue)
        }).finally(() => {
          this.isSaving = false
        })
      }
    }
  }
}
</script>

<style lang="scss">
.dwca-vscroll {
  height: calc(100vh - 250px);
  overflow: auto;
  overflow-anchor: none;
}
.dwca-table {
  th {
    top: 0;
    z-index: 2101;
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
  .row-empty {
    background: linear-gradient(transparent,transparent 20%,hsla(0,0%,50.2%,0.03) 0,hsla(0,0%,50.2%,0.08) 50%,hsla(0,0%,50.2%,0.03) 80%,transparent 0,transparent);
    background-size:100% 40px
  }
  .dwc-table-cell {
    display: table-cell;
    height: 40px;
    max-width: 200px;
    text-overflow: ellipsis;
    white-space: nowrap;
    overflow: hidden;
    vertical-align: middle
  }
}
</style>
