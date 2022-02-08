<template>
  <div>
    <modal-component
      v-if="showModal"
      :container-style="{ width: '500px', 'overflow-y': 'scroll', 'max-height': '60vh' }"
      @close="closeModal">
      <template #header>
        <h3>Copy descriptors from matrix</h3>
      </template>
      <template #body>
        <spinner-component
          v-if="isLoading"
          legend="Loading..."/>
        <select
          class="full_width margin-medium-bottom"
          v-model="matrixSelected">
          <option :value="undefined">
            Select a observation matrix
          </option>
          <option
            v-for="item in observationMatrices"
            :key="item.id"
            :value="item">
            {{ item.name }}
          </option>
        </select>
        <div
          v-if="matrixSelected"
          class="flex-separate margin-small-bottom">
          <div>
            <button
              @click="addDescriptors"
              :disabled="!descriptorsSelected.length"
              class="button normal-input button-submit">
              Add descriptors
            </button>
          </div>
          <div v-if="matrixSelected">
            <button
              class="button normal-input button-default"
              @click="selectAll">
              Select all
            </button>
            <button
              class="button normal-input button-default"
              @click="unselectAll">
              Unselect all
            </button>
          </div>
        </div>
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
      </template>
      <template #footer>
        <div
          v-if="matrixSelected"
          class="flex-separate">
          <div>
            <button
              @click="addDescriptors"
              :disabled="!descriptorsSelected.length"
              class="button normal-input button-submit">
              Add descriptors
            </button>
          </div>
          <div>
            <button
              class="button normal-input button-default"
              @click="selectAll">
              Select all
            </button>
            <button
              class="button normal-input button-default"
              @click="unselectAll">
              Unselect all
            </button>
          </div>
        </div>
      </template>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal'
import SpinnerComponent from 'components/spinner'
import ObservationTypes from '../../const/types.js'

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { ObservationMatrix, ObservationMatrixColumnItem } from 'routes/endpoints'
import {
  GetMatrixObservationColumns
} from '../../request/resources'

export default {
  components: {
    ModalComponent,
    SpinnerComponent
  },

  props: {
    matrixId: {
      type: [String, Number],
      required: true
    }
  },

  emits: ['close'],

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
      showModal: true,
      observationMatrices: []
    }
  },

  watch: {
    showModal: {
      handler (newVal) {
        if (newVal) {
          this.isLoading = true
          ObservationMatrix.where({ per: 500 }).then(response => {
            response.body.splice(response.body.findIndex(item => this.matrixId === item.id), 1)
            this.observationMatrices = response.body
            this.isLoading = false
          })
        }
      },
      immediate: true
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
      this.isLoading = true
      GetMatrixObservationColumns(matrixId, { per: 500 }).then(response => {
        this.descriptors = response.body
        this.isLoading = false
      })
    },

    addDescriptors () {
      const promises = []
      const index = this.columns.length
      const data = this.descriptorsSelected.map(item => ({
        observation_matrix_id: this.matrixId,
        descriptor_id: item.descriptor_id,
        position: item.position + index,
        type: ObservationTypes.Column.Descriptor
      }))

      data.sort((a, b) => a - b)
      console.log(data.sort((a, b) => a.position - b.position))

      data.forEach(descriptor => { promises.push(ObservationMatrixColumnItem.create({ observation_matrix_column_item: descriptor })) })

      Promise.all(promises).then(() => {
        this.$store.dispatch(ActionNames.GetMatrixObservationColumns, this.matrixId)
        this.descriptorsSelected = []
        TW.workbench.alert.create('Descriptors was successfully added to matrix.', 'notice')
        this.closeModal()
      })
    },

    alreadyExist (item) {
      return this.columns.find(column => item.descriptor_id === column.descriptor_id)
    },

    closeModal () {
      this.showModal = false
      this.$emit('close')
    },

    selectAll () {
      this.descriptorsSelected = this.descriptors.filter(item => !this.alreadyExist(item))
    },

    unselectAll () {
      this.descriptorsSelected = []
    }
  }
}
</script>
