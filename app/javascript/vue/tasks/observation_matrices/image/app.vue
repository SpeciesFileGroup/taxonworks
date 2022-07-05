<template>
  <div id="vue-matrix-image">
    <spinner-component
      v-if="isLoading || isSaving"
      full-screen
      :legend="isSaving
        ? 'Saving changes...'
        : 'Loading observation matrix...'
      "
      :logo-size="{ width: '100px', height: '100px'}"
    />
    <row-modal
      v-if="showRowModal"
      :matrix-id="observationMatrix.id"
      @close="showRowModal = false"
      @create="addRow"
    />
    <column-modal
      v-if="showColumnModal"
      :matrix-id="observationMatrix.id"
      @close="showColumnModal = false"
      @create="addColumn"
    />
    <div class="flex-separate">
      <h1>Image matrix</h1>
      <ul class="context-menu">
        <li>
          <label class="cursor-pointer middle">
            <input
              v-model="viewMode"
              type="checkbox"
            >
            View mode
          </label>
        </li>
        <template v-if="matrixId">
          <li>
            <span
              class="cursor-pointer"
              @click="showColumnModal = true"
            >
              Add column
            </span>
          </li>
          <li>
            <span
              class="cursor-pointer"
              @click="collapseAll"
            >
              Collapse all
            </span>
          </li>
          <li>
            <span
              class="cursor-pointer"
              data-icon="reset"
              @click="resetTable"
            >
              Reset
            </span>
          </li>
        </template>
        <li>
          <a :href="RouteNames.ObservationMatricesDashboard">Observation matrix dashboard</a>
        </li>
        <li>
          <a :href="RouteNames.ObservationMatricesHub">Observation matrix hub</a>
        </li>
      </ul>
    </div>
    <pagination-component
      v-if="pagination"
      @next-page="loadPage"
      :pagination="pagination"
    />
    <h3 v-if="observationMatrix">
      {{ observationMatrix.object_tag }}
    </h3>
    <template v-if="!viewMode">
      <matrix-table
        class="separate-autocomplete"
        ref="matrixTable"
        :columns="observationColumns"
        :rows="observationRows"
      />
    </template>
    <view-component
      v-if="viewMode"
      :matrix-id="matrixId"
      :otus-id="otuFilter"
    />
  </div>
</template>

<script>
import { Otu } from 'routes/endpoints'
import { GetterNames } from './store/getters/getters'
import { RouteNames } from 'routes/routes'
import { ActionNames } from './store/actions/actions'

import MatrixTable from './components/MatrixTable.vue'
import SpinnerComponent from 'components/spinner.vue'
import RowModal from './components/RowModal.vue'
import ColumnModal from './components/ColumnModal.vue'
import ViewComponent from './components/View/Main.vue'
import setParam from 'helpers/setParam'
import PaginationComponent from 'components/pagination.vue'

export default {
  components: {
    ViewComponent,
    MatrixTable,
    SpinnerComponent,
    RowModal,
    ColumnModal,
    PaginationComponent
  },

  computed: {
    isSaving () {
      return this.$store.getters[GetterNames.GetIsSaving]
    },
    isLoading () {
      return this.$store.getters[GetterNames.GetIsLoading]
    },
    matrixId () {
      return this.observationMatrix?.id
    },
    observationColumns () {
      return this.$store.getters[GetterNames.GetObservationColumns]
    },
    observationMatrix () {
      return this.$store.getters[GetterNames.GetObservationMatrix]
    },
    observationRows () {
      return this.$store.getters[GetterNames.GetObservationRows]
    },
    pagination () {
      return this.$store.getters[GetterNames.GetPagination]
    },
    RouteNames: () => RouteNames
  },

  data () {
    return {
      showRowModal: false,
      showColumnModal: false,
      maxPerPage: 3,
      viewMode: false,
      otuFilter: []
    }
  },

  created () {
    const urlParams = new URLSearchParams(window.location.search)
    const obsIdParam = urlParams.get('observation_matrix_id')
    const otuFilterParam = urlParams.get('otu_filter')
    const rowFilterParam = urlParams.get('row_filter')
    const page = urlParams.get('page')

    this.viewMode = (urlParams.get('view') === 'true')

    if (otuFilterParam) {
      this.otuFilter = otuFilterParam
    }

    if (/^\d+$/.test(obsIdParam) || otuFilterParam) {
      this.$store.dispatch(ActionNames.LoadObservationMatrix, {
        observation_matrix_id: (/^\d+$/.test(obsIdParam) && obsIdParam) || 0,
        otu_filter: otuFilterParam,
        row_filter: rowFilterParam,
        page
      })
    }
  },

  methods: {
    resetTable () {
      this.$refs.matrixTable.reset()
    },

    collapseAll () {
      this.$refs.matrixTable.collapseAll()
    },

    addRow (row) {
      this.showRowModal = false
      if (row.otu_id) {
        Otu.find(row.otu_id).then(response => {
          row.observation_object = response.body
          this.observationRows.push(row)
        })
      }
    },

    addColumn (column) {
      this.showColumnModal = false
      this.observationColumns.push(column)
    },

    loadPage ({ page }) {
      this.$store.dispatch(ActionNames.LoadObservationMatrix, {
        observation_matrix_id: this.matrixId,
        page
      })
      setParam(RouteNames.ImageMatrix, 'observation_matrix_id', this.matrixId)
      setParam(RouteNames.ImageMatrix, 'page', page)
    }

  }
}
</script>
<style scoped>
.separate-autocomplete {
  margin-top: 100px;
}
</style>
