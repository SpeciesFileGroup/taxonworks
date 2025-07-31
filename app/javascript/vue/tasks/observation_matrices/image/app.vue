<template>
  <div id="vue-matrix-image">
    <spinner-component
      v-if="isLoading || isSaving"
      full-screen
      :legend="isSaving ? 'Saving changes...' : 'Loading observation matrix...'"
      :logo-size="{ width: '100px', height: '100px' }"
    />
    <column-modal
      v-if="showColumnModal"
      :matrix-id="observationMatrix.id"
      @close="showColumnModal = false"
    />
    <div class="flex-separate">
      <h1>Image matrix</h1>
      <ul class="context-menu">
        <li v-if="editMode">
          <label class="cursor-pointer middle">
            <input
              v-model="isClone"
              type="checkbox"
            />
            Clone mode
          </label>
        </li>
        <li>
          <label class="cursor-pointer middle">
            <input
              v-model="editMode"
              type="checkbox"
            />
            Edit mode
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
          <a :href="RouteNames.ObservationMatricesDashboard"
            >Observation matrix dashboard</a
          >
        </li>
        <li>
          <a :href="RouteNames.ObservationMatricesHub"
            >Observation matrix hub</a
          >
        </li>
      </ul>
    </div>
    <div class="flex-separate">
      <pagination-component
        v-if="pagination"
        @next-page="loadPage"
        :pagination="pagination"
      />
      <pagination-count
        :pagination="pagination"
        v-model="per"
      />
    </div>
    <h3 v-if="observationMatrix">
      {{ observationMatrix.object_tag }}
    </h3>
    <template v-if="editMode">
      <matrix-table
        class="separate-autocomplete"
        ref="matrixTable"
        :columns="observationColumns"
        :rows="observationRows"
      />
    </template>
    <view-component
      v-else
      :matrix-id="matrixId"
    />
  </div>
</template>

<script>
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations.js'
import { RouteNames } from '@/routes/routes'
import { ActionNames } from './store/actions/actions'
import { URLParamsToJSON } from '@/helpers'

import MatrixTable from './components/MatrixTable.vue'
import SpinnerComponent from '@/components/ui/VSpinner.vue'
import ColumnModal from './components/ColumnModal.vue'
import ViewComponent from './components/View/Main.vue'
import setParam from '@/helpers/setParam'
import PaginationComponent from '@/components/pagination.vue'
import PaginationCount from '@/components/pagination/PaginationCount.vue'

export default {
  name: 'ImageMatrix',

  components: {
    ViewComponent,
    MatrixTable,
    SpinnerComponent,
    ColumnModal,
    PaginationComponent,
    PaginationCount
  },

  computed: {
    isSaving() {
      return this.$store.getters[GetterNames.GetIsSaving]
    },
    isLoading() {
      return this.$store.getters[GetterNames.GetIsLoading]
    },
    matrixId() {
      return this.observationMatrix?.id
    },
    observationColumns() {
      return this.$store.getters[GetterNames.GetObservationColumns]
    },
    observationMatrix() {
      return this.$store.getters[GetterNames.GetObservationMatrix]
    },
    observationRows() {
      return this.$store.getters[GetterNames.GetObservationRows]
    },
    pagination() {
      return this.$store.getters[GetterNames.GetPagination]
    },
    isClone: {
      get() {
        return this.$store.getters[GetterNames.IsClone]
      },

      set(value) {
        this.$store.commit(MutationNames.SetClone, value)
      }
    },
    RouteNames: () => RouteNames
  },

  data() {
    return {
      showColumnModal: false,
      maxPerPage: 3,
      editMode: true,
      per: 100,
      otuFilter: []
    }
  },

  watch: {
    per() {
      this.loadPage({ page: this.pagination.paginationPage })
    }
  },

  created() {
    const urlParams = URLParamsToJSON(window.location.href)
    const obsIdParam = urlParams.observation_matrix_id
    const otuFilterParam = urlParams.otu_filter || urlParams.otu_id?.join('|')
    const rowFilterParam = urlParams.row_filter
    const page = urlParams.page

    this.editMode = urlParams.edit

    if (otuFilterParam) {
      this.otuFilter = otuFilterParam
    }

    if (/^\d+$/.test(obsIdParam) || otuFilterParam) {
      this.$store.dispatch(ActionNames.LoadObservationMatrix, {
        observation_matrix_id: (/^\d+$/.test(obsIdParam) && obsIdParam) || 0,
        otu_filter: otuFilterParam,
        row_filter: rowFilterParam,
        page,
        per: this.per
      })
    }
  },

  methods: {
    resetTable() {
      this.$refs.matrixTable.reset()
    },

    collapseAll() {
      this.$refs.matrixTable.collapseAll()
    },

    loadPage({ page }) {
      this.$store.dispatch(ActionNames.LoadObservationMatrix, {
        observation_matrix_id: this.matrixId || 0,
        page,
        otu_filter: this.otuFilter,
        per: this.per
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
