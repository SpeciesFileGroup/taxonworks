<template>
  <div>
    <button
      class="button normal-input button-default"
      @click="showModal = true">Copy descriptors</button>
    <modal-component
      v-if="showModal"
      :container-style="{ width: '500px' }"
      @close="showModal = false">
      <h3 slot="header">Copy descriptors from matrix</h3>
      <div slot="body">
        <spinner-component
          v-if="isLoading"
          legend="Loading observation matrices..."/>
        <select
          class="full_width margin-medium-bottom"
          v-model="matrixSelected">
          <option :value="undefined"> Select a observation matrix </option>
          <option
            v-for="item in observationMatrices"
            :key="item.id"
            :value="item">
            {{ item.name }}
          </option>
        </select>
        <ul
          class="no_bullets">
          <li
            v-for="item in descriptors"
            :key="item.descriptor.id">
            <label>
              <input
                type="checkbox"
                :value="item"
                v-model="descriptorsSelected"
                :disabled="alreadyExist(item)">
              <span
                class="disabled"
                v-if="alreadyExist(item)"> {{ item.descriptor.name }} ({{ item.descriptor.type }}) <span>(Already added)</span></span>
              <span v-else>
                {{ item.descriptor.name }} ({{ item.descriptor.type }})
              </span>
            </label>
          </li>
        </ul>
      </div>
      <button
        slot="footer"
        @click="addDescriptors"
        :disabled="!descriptorsSelected.length"
        class="button normal-input button-submit">
        Add descriptors
      </button>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import SmartSelector from 'components/smartSelector'
import SpinnerComponent from 'components/spinner'

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { GetMatrixObservation, GetMatrixObservationColumns, CreateColumnItem, GetObservationMatrices } from '../../request/resources'

export default {
  components: {
    ModalComponent,
    SmartSelector,
    SpinnerComponent
  },
  props: {
    matrixId: {
      type: [String, Number],
      required: true
    }
  },
  computed: {
    columns () {
      return this.$store.getters[GetterNames.GetMatrixColumns]
    }
  },
  data () {
    return {
      isLoading: false,
      matrixSelected: undefined,
      descriptorsSelected: [],
      descriptors: [],
      showModal: false,
      observationMatrices: []
    }
  },
  watch: {
    showModal (newVal) {
      if (newVal) {
        this.isLoading = true
        GetObservationMatrices().then(response => {
          this.observationMatrices = response
          this.isLoading = false
        })
      }
    },
    matrixSelected (newVal) {
      if (newVal) {
        this.loadDescriptors(newVal.id)
      } else {
        this.descriptors = []
      }
    }
  },
  methods: {
    loadDescriptors (matrixId) {
      GetMatrixObservationColumns(matrixId).then(response => {
        this.descriptors = response
      })
    },
    addDescriptors () {
      const promises = []
      const index = this.columns.length
      const data = this.descriptorsSelected.map(item => {
        return {
          observation_matrix_id: this.matrixId,
          descriptor_id: item.descriptor_id,
          position: item.position + index,
          type: 'ObservationMatrixColumnItem::SingleDescriptor'
        }
      })

      data.sort((a, b) => { return a - b })
      console.log(data.sort((a, b) => { return a.position - b.position }))

      data.forEach(descriptor => { promises.push(CreateColumnItem({ observation_matrix_column_item: descriptor })) })

      Promise.all(promises).then(() => {
        this.$store.dispatch(ActionNames.GetMatrixObservationColumns, this.matrixId)
        this.descriptorsSelected = []
        TW.workbench.alert.create('Descriptors was successfully added to matrix.', 'notice')
      })
    },
    alreadyExist (item) {
      return this.columns.find(column => {
        return item.descriptor_id === column.descriptor_id
      })
    }
  }
}
</script>

<style>

</style>