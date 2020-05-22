<template>
  <div>
    <modal-component
      v-if="showModal"
      :container-style="{ width: '500px' }"
      @close="showModal = false">
      <h3 slot="header">Copy rows from matrix</h3>
      <div slot="body">
        <spinner-component
          v-if="isLoading"
          legend="Loading observation matrices..."/>
        <select
          class="full_width margin-medium-bottom"
          v-model="matrixSelected">
          <option :value="undefined">Select a observation matrix</option>
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
            v-for="item in rows"
            :key="item.row_object.id">
            <label>
              <input
                type="checkbox"
                :value="item"
                v-model="rowsSelected"
                :disabled="alreadyExist(item)">
              <span
                class="disabled"
                v-if="alreadyExist(item)"> <span v-html="item.row_object.object_tag" /> ({{ item.row_object.base_class }}) <span>(Already added)</span></span>
              <span v-else>
                <span v-html="item.row_object.object_tag" /> ({{ item.row_object.base_class }})
              </span>
            </label>
          </li>
        </ul>
      </div>
      <button
        slot="footer"
        @click="addRows"
        :disabled="!rowsSelected.length"
        class="button normal-input button-submit">
        Add rows
      </button>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import SpinnerComponent from 'components/spinner'

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { GetMatrixObservationRows, GetObservationMatrices, CreateRowItem } from '../../request/resources'

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
  computed: {
    existingRows () {
      return this.$store.getters[GetterNames.GetMatrixRows]
    }
  },
  data () {
    return {
      types: {
        Otu: 'ObservationMatrixRowItem::SingleOtu',
        CollectionObject: 'ObservationMatrixRowItem::SingleCollectionObject',
      },
      isLoading: false,
      matrixSelected: undefined,
      rowsSelected: [],
      rows: [],
      showModal: true,
      observationMatrices: []
    }
  },
  watch: {
    showModal: {
      handler (newVal) {
        if (newVal) {
          this.isLoading = true
          GetObservationMatrices().then(response => {
            response.splice(response.findIndex(item => { return this.matrixId === item.id }), 1)
            this.observationMatrices = response
            this.isLoading = false
          })
        }
      },
      immediate: true
    },
    matrixSelected (newVal) {
      if (newVal) {
        this.loadRows(newVal.id)
      } else {
        this.rows = []
      }
    }
  },
  methods: {
    loadRows (matrixId) {
      GetMatrixObservationRows(matrixId).then(response => {
        this.rows = response
      })
    },
    addRows () {
      const promises = []
      const index = this.existingRows.length
      const data = this.rowsSelected.map(item => {
        return {
          observation_matrix_id: this.matrixId,
          [(item.row_object.base_class === 'Otu' ? 'otu_id' : 'collection_object_id')]: item.row_object.id,
          position: item.position + index,
          type: this.types[item.row_object.base_class]
        }
      })

      data.sort((a, b) => { return a - b })
      console.log(data.sort((a, b) => { return a.position - b.position }))

      data.forEach(row => { promises.push(CreateRowItem({ observation_matrix_row_item: row })) })

      Promise.all(promises).then(() => {
        this.$store.dispatch(ActionNames.GetMatrixObservationRows, this.matrixId)
        this.rowsSelected = []
        TW.workbench.alert.create('Rows was successfully added to matrix.', 'notice')
      })
    },
    alreadyExist (item) {
      return this.existingRows.find(row => {
        return item.row_object.id === row.row_object.id
      })
    }
  }
}
</script>
