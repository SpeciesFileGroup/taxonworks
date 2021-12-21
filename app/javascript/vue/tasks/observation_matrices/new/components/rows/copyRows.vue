<template>
  <div>
    <modal-component
      v-if="showModal"
      :container-style="{ width: '500px', 'overflow-y': 'scroll', 'max-height': '60vh' }"
      @close="closeModal">
      <template #header>
        <h3>Copy rows from matrix</h3>
      </template>
      <template #body>
        <spinner-component
          v-if="isLoading"
          legend="Loading..."/>
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
        <div
          v-if="matrixSelected"
          class="flex-separate margin-small-bottom">
          <div>
            <button
              @click="addRows"
              :disabled="!rowsSelected.length"
              class="button normal-input button-submit">
              Add rows
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
      </template>
      <template #footer>
        <div class="flex-separate">
          <div>
            <button
              @click="addRows"
              :disabled="!rowsSelected.length"
              class="button normal-input button-submit">
              Add rows
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
      </template>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal'
import SpinnerComponent from 'components/spinner'
import getPagination from 'helpers/getPagination'

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { GetMatrixObservationRows } from '../../request/resources'
import {
  ObservationMatrix,
  ObservationMatrixRowItem
} from 'routes/endpoints'
import ObservationTypes from '../../const/types.js'

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
      types: ObservationTypes.Row,
      isLoading: false,
      matrixSelected: undefined,
      rowsSelected: [],
      rows: [],
      showModal: true,
      observationMatrices: [],
      pagination: undefined
    }
  },

  watch: {
    showModal: {
      handler (newVal) {
        if (newVal) {
          this.isLoading = true
          ObservationMatrix.all().then(response => {
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
        this.loadRows()
      } else {
        this.rows = []
      }
    }
  },

  mounted () {
    document.addEventListener('turbolinks:load', () => { window.removeEventListener('scroll', this.checkScroll) })
    this.$el.querySelector('.modal-container').addEventListener('scroll', this.checkScroll)
  },

  methods: {
    loadRows (page = undefined) {
      this.isLoading = true
      GetMatrixObservationRows(this.matrixSelected.id, { per: 500, page: page }).then(response => {
        this.rows = this.rows.concat(response.body)
        this.pagination = getPagination(response)
        this.isLoading = false
      })
    },
    addRows () {
      const index = this.existingRows.length
      const data = this.rowsSelected.map(item => {
        const property = item.row_object.base_class === 'Otu'
          ? 'otu_id'
          : 'collection_object_id'

        return {
          observation_matrix_id: this.matrixId,
          [property]: item.row_object.id,
          position: item.position + index,
          type: this.types[item.row_object.base_class]
        }
      })

      data.sort((a, b) => a - b)

      const promises = data.map(row => ObservationMatrixRowItem.create({ observation_matrix_row_item: row }))

      Promise.all(promises).then(() => {
        this.$store.dispatch(ActionNames.GetMatrixObservationRows)
        this.rowsSelected = []
        TW.workbench.alert.create('Rows was successfully added to matrix.', 'notice')
        this.closeModal()
      })
    },
    alreadyExist (item) {
      return this.existingRows.find(row => item.row_object.id === row.row_object.id)
    },
    closeModal () {
      this.showModal = false
      this.$emit('close')
    },
    selectAll () {
      this.rowsSelected = this.rows.filter(item => !this.alreadyExist(item))
    },
    unselectAll () {
      this.rowsSelected = []
    },
    checkScroll (event) {
      const scrollPosition = event.target.clientHeight + event.target.scrollTop
      const listHeght = event.target.scrollHeight

      const bottomOfTable = (scrollPosition >= listHeght)
      if (bottomOfTable && !this.isLoading) {
        if (this.pagination.nextPage) {
          this.loadRows(this.pagination.nextPage)
        }
      }
    }
  }
}
</script>
