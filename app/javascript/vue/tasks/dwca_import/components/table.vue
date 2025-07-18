<template>
  <div>
    <div class="horizontal-right-content margin-medium-bottom">
      <CheckboxIgnoreColumns />
    </div>
    <virtual-scroller
      :items="list"
      :item-height="43"
      class="dwca-vscroll"
      ref="table"
      @update="getPages"
    >
      <template #default="{ items }">
        <spinner-component
          legend="Updating records..."
          v-if="isSaving"
        />
        <spinner-component v-if="isLoading" />
        <table class="dwca-table">
          <thead>
            <tr>
              <th class="position-sticky">Options</th>
              <status-filter
                class="position-sticky margin-medium-left"
                :disabled="isProcessing"
                v-model="params.status"
              />
              <template
                v-for="(item, index) in datasetHeaders"
                :key="item"
              >
                <column-filter
                  v-if="settings.ignoredColumns || !isIgnored(index)"
                  :title="item"
                  :disabled="isProcessing"
                  :column-index="index"
                  :ignored="isIgnored(index)"
                  v-model="params.filter[index]"
                  :field="index"
                  @replace="replaceField"
                />
              </template>
            </tr>
          </thead>
          <tbody>
            <template
              v-for="(item, index) in items"
              :key="index"
            >
              <row-component
                v-if="item"
                class="contextMenuCells"
                :class="{ hightlight: currentRowIndex === item.id }"
                :row="item"
                @click="() => highlightRow(item.id)"
              />
              <tr
                v-else
                class="row-empty contextMenuCells"
              >
                <td
                  style="height: 40px"
                  colspan="100"
                >
                  <div class="dwc-table-cell" />
                </td>
              </tr>
            </template>
          </tbody>
        </table>
      </template>
    </virtual-scroller>
    <confirmation-modal ref="confirmation" />
  </div>
</template>

<script>
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import { UpdateColumnField } from '../request/resources'
import VirtualScroller from './VirtualScroller.vue'
import SpinnerComponent from '@/components/ui/VSpinner'

import RowComponent from './row'
import ColumnFilter from './ColumnFilter'
import StatusFilter from './StatusFilter'
import CheckboxIgnoreColumns from './settings/CheckboxIgnoreColumns.vue'
import ConfirmationModal from '@/components/ConfirmationModal'
import VIcon from '@/components/ui/VIcon/index.vue'

export default {
  components: {
    ConfirmationModal,
    VirtualScroller,
    RowComponent,
    ColumnFilter,
    StatusFilter,
    SpinnerComponent,
    VIcon,
    CheckboxIgnoreColumns
  },

  computed: {
    params: {
      get() {
        return this.$store.getters[GetterNames.GetParamsFilter]
      },
      set(value) {
        this.$store.commit(MutationNames.SetParamsFilter, value)
      }
    },
    datasetHeaders() {
      const metadata = this.$store.getters[GetterNames.GetDataset].metadata
      return metadata ? metadata.core_headers : []
    },
    datasetRecords() {
      return this.$store.getters[GetterNames.GetDatasetRecords]
    },
    dataset() {
      return this.$store.getters[GetterNames.GetDataset]
    },
    list() {
      return [].concat(
        ...this.datasetRecords.map((page) =>
          page.rows ? page.rows : new Array(page.count)
        )
      )
    },
    currentVirtualPage() {
      return this.$store.getters[GetterNames.GetCurrentVirtualPage]
    },
    importId() {
      return this.$store.getters[GetterNames.GetDataset].id
    },
    pagination() {
      return this.$store.getters[GetterNames.GetPagination]
    },
    isProcessing() {
      return this.$store.getters[GetterNames.GetSettings].isProcessing
    },
    settings() {
      return this.$store.getters[GetterNames.GetSettings]
    },
    currentRowIndex: {
      get() {
        return this.$store.getters[GetterNames.GetCurrentRowIndex]
      },
      set(value) {
        this.$store.commit(MutationNames.SetCurrentRowIndex, value)
      }
    }
  },

  data() {
    return {
      isLoading: false,
      isSaving: false
    }
  },

  watch: {
    params: {
      handler() {
        if (!this.dataset.id) return
        this.$refs.table.$el.scrollTop = 0
        this.isLoading = true
        this.$store.dispatch(ActionNames.LoadDatasetRecords).then(() => {
          this.isLoading = false
        })
      },
      deep: true
    },

    currentVirtualPage() {
      this.$refs.table.$el.scrollTop = 0
    }
  },

  methods: {
    loadPage(pages) {
      pages.forEach((page) => {
        this.$store.dispatch(ActionNames.LoadDatasetRecords, page)
      })
    },

    isIgnored(index) {
      return !this.dataset.metadata?.core_records_mapped_fields?.includes(index)
    },

    getPages(indexes) {
      const pages = [
        Math.floor(indexes.endIndex / this.params.per),
        Math.ceil(indexes.endIndex / this.params.per)
      ].map((page) => (page === 0 ? 1 : page))
      this.loadPage(pages)
    },

    async replaceField({ columnIndex, replaceValue, currentValue }) {
      const ok = await this.$refs.confirmation.show({
        title: this.datasetHeaders[columnIndex],
        message: `<i>${currentValue}</i> will be replaced with <i>${replaceValue}</i> in ${this.pagination.total} records.`,
        typeButton: 'submit',
        cancelButton: 'Cancel'
      })
      if (ok) {
        this.isSaving = true
        UpdateColumnField(
          this.importId,
          Object.assign(
            {},
            {
              field: columnIndex,
              value: replaceValue
            },
            this.params
          )
        )
          .then(() => {
            this.params.filter[columnIndex] = replaceValue
          })
          .finally(() => {
            this.isSaving = false
          })
      }
    },

    highlightRow(index) {
      this.currentRowIndex = index
    }
  }
}
</script>

<style lang="scss">
.dwca-vscroll {
  height: calc(100vh - 280px);
  overflow: auto;
  overflow-anchor: none;
}
.dwca-table {
  th {
    top: 0;
    z-index: 2101;
    border-left: 1px solid var(--border-color);
    border-right: 1px solid var(--border-color);
    box-shadow: inset 0 -2px 0 var(--border-color);
    border-bottom: none;
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
    background: linear-gradient(
      transparent,
      transparent 20%,
      hsla(0, 0%, 50.2%, 0.03) 0,
      hsla(0, 0%, 50.2%, 0.08) 50%,
      hsla(0, 0%, 50.2%, 0.03) 80%,
      transparent 0,
      transparent
    );
    background-size: 100% 40px;
  }
  .dwc-table-cell {
    display: table-cell;
    height: 40px;
    max-width: 200px;
    text-overflow: ellipsis;
    white-space: nowrap;
    overflow: hidden;
    vertical-align: middle;
  }

  .hightlight {
    outline: 2px solid var(--color-primary) !important;
    outline-offset: -2px;
  }

  .cell-ignore {
    background-color: var(--soft-validation-bg-color);
  }

  tr:hover {
    td.cell-ignore {
      background-color: inherit;
    }
  }
}
</style>
