<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default margin-small-bottom"
      @click="setModelView(true)">
      Select
    </button>
    <modal-component
      v-if="showModal"
      @close="setModelView(false)"
      :container-style="{
        width: '500px',
        overflow: 'scroll',
        maxHeight: '80vh'
      }">
      <template #header>
        <h3>Row filter</h3>
      </template>
      <template #body>
        <div class="margin-small-bottom">
          <button
            v-if="allSelected"
            type="button"
            class="button normal-input button-default margin-small-bottom"
            @click="unselectAll">
            Unselect all
          </button>
          <button
            v-else
            type="button"
            class="button normal-input button-default margin-small-bottom"
            @click="selectAll">
            Select all
          </button>
          <button
            type="button"
            class="button normal-input button-default"
            @click="closeAndApply">
            Apply filter
          </button>
          <button-image-matrix
            :otu-ids="this.selectedRows"/>
        </div>
        <ul class="no_bullets">
          <li
            v-for="item in remaining"
            :key="item.object.id"
            class="margin-small-bottom middle">
            <label>
              <input
                v-model="selectedRows"
                :value="item.object.id"
                type="checkbox">
              <span v-html="displayLabel(item.object)"/>
            </label>
          </li>
        </ul>
      </template>
      <template #footer>
        <div>
          <button
            v-if="allSelected"
            type="button"
            class="button normal-input button-default margin-small-bottom"
            @click="unselectAll">
            Unselect all
          </button>
          <button
            v-else
            type="button"
            class="button normal-input button-default margin-small-bottom"
            @click="selectAll">
            Select all
          </button>
          <button
            type="button"
            class="button normal-input button-default"
            @click="closeAndApply">
            Apply filter
          </button>
          <button-image-matrix
            :otu-ids="this.selectedRows"/>
        </div>
      </template>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal'
import ExtendResult from './extendResult'
import RanksList from '../const/ranks'
import ButtonImageMatrix from 'tasks/observation_matrices/dashboard/components/buttonImageMatrix.vue'
import { MutationNames } from '../store/mutations/mutations'
import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'

export default {
  mixins: [ExtendResult],

  components: {
    ModalComponent,
    ButtonImageMatrix
  },

  computed: {
    remaining () {
      return this.observationMatrix ? this.observationMatrix.remaining : []
    },

    filters () {
      return this.$store.getters[GetterNames.GetParamsFilter]
    },

    rowFilter: {
      get () {
        return this.$store.getters[GetterNames.GetRowFilter]
      },
      set (value) {
        this.$store.commit(MutationNames.SetRowFilter, value)
      }
    },

    allSelected () {
      return Object.keys(this.selectedRows).length === this.remaining.length
    }
  },

  data () {
    return {
      showModal: false,
      selectedRows: []
    }
  },

  watch: {
    showModal (newVal) {
      if (newVal) {
        this.selectedRows = this.rowFilter
      }
    }
  },
  methods: {
    displayLabel (obj) {
      return this.filters.identified_to_rank && obj.base_class !== 'ObservationMatrixRow' ? obj[RanksList[this.filters.identified_to_rank].label] : obj.object_tag
    },

    setModelView (value) {
      this.showModal = value
    },

    LoadObservationMatrix () {
      this.$store.dispatch(ActionNames.LoadObservationMatrix, this.observationMatrix.observation_matrix_id)
      document.querySelector('.descriptors-view div').scrollIntoView(0)
    },

    selectAll () {
      this.selectedRows = this.remaining.map(item => item.object.id)
    },

    unselectAll () {
      this.selectedRows = []
    },

    closeAndApply () {
      this.rowFilter = this.selectedRows
      this.LoadObservationMatrix()
      this.setModelView(false)
    }
  }
}
</script>
