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
      @close="closeAndApply"
      :container-style="{
        width: '500px',
        overflow: 'scroll',
        maxHeight: '80vh'
      }">
      <h3 slot="header">Row filter</h3>
      <div slot="body">
        <div class="margin-small-bottom">
          <button
            type="button"
            class="button normal-input button-default"
            @click="closeAndApply">
            Apply filter
          </button>
          <button
            type="button"
            class="button normal-input button-default"
            @click="openImageMatrix">
            Open image matrix
          </button>
          <link-image-matrix
            :otu-ids="this.rowFilter"/>
        </div>
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
        <ul class="no_bullets">
          <li
            v-for="item in remaining"
            :key="item.object.id"
            class="margin-small-bottom middle">
            <label>
              <input
                v-model="rowFilter"
                :value="item.object.id"
                type="checkbox">
              <span v-html="displayLabel(item.object)"/>
            </label>
          </li>
        </ul>
      </div>
      <div slot="footer">
        <button
          type="button"
          class="button normal-input button-default"
          @click="closeAndApply">
          Apply filter
        </button>
        <button
          type="button"
          class="button normal-input button-default"
          @click="openImageMatrix">
          Open image matrix
        </button>
        <link-image-matrix
          :otu-ids="this.rowFilter"/>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import ExtendResult from './extendResult'
import RanksList from '../const/ranks'
import LinkImageMatrix from 'tasks/observation_matrices/dashboard/components/buttonImageMatrix.vue'
import { MutationNames } from '../store/mutations/mutations'
import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import { RouteNames } from 'routes/routes'

export default {
  mixins: [ExtendResult],
  components: {
    ModalComponent,
    LinkImageMatrix
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
      return Object.keys(this.rowFilter).length === this.remaining.length
    }
  },
  data () {
    return {
      showModal: false
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
      this.rowFilter = this.remaining.map(item => item.object.id)
    },
    unselectAll () {
      this.rowFilter = []
    },
    closeAndApply () {
      this.LoadObservationMatrix()
      this.setModelView(false)
    },
    openImageMatrix () {
      const otuIds = this.rowFilter.map(id => this.remaining.find(r => r.object.id === id)).map(otu => otu.object.otu_id)
      window.open(`${RouteNames.ImageMatrix}?observation_matrix_id=${this.observationMatrix.observation_matrix_id}&otu_ids=${otuIds.join('|')}`, '_blank')
    }
  }
}
</script>
