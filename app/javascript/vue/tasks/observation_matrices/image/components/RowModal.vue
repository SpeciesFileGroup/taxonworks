<template>
  <modal-component @close="$emit('close', true)">
    <spinner-component v-if="saving"/>
    <template #header>
      <h3>Create new row</h3>
    </template>
    <template #body>
      <ul class="no_bullets">
        <li
          v-for="item in types"
          :key="item">
          <label>
            <input
              type="radio"
              v-model="type"
              :value="item">
            {{ item }}
          </label>
        </li>
      </ul>
      <div
        class="separate-top"
        v-if="type === 'Otu'">
        <otu-picker @get-item="createRow"/>
      </div>
    </template>
  </modal-component>
</template>

<script>

import ModalComponent from 'components/ui/Modal.vue'
import OtuPicker from 'components/otu/otu_picker/otu_picker.vue'
import SpinnerComponent from 'components/spinner'
import { ObservationMatrixRowItem } from 'routes/endpoints'
import { 
  COLLECTION_OBJECT,
  OBSERVATION_MATRIX_ROW_SINGLE,
  OTU
} from 'constants/index.js'

export default {
  components: {
    ModalComponent,
    OtuPicker,
    SpinnerComponent
  },

  props: {
    matrixId: {
      type: [Number, String],
      required: true
    }
  },

  emits: ['create'],

  data () {
    return {
      types: [
        OTU,
        COLLECTION_OBJECT
      ],
      type: OTU,
      saving: false
    }
  },

  methods: {
    createRow (object) {
      const observation_matrix_row_item = {
        observation_matrix_id: this.matrixId,
        observation_object_id: object.id,
        observation_object_type: this.type,
        type: OBSERVATION_MATRIX_ROW_SINGLE
      }

      this.saving = true
      ObservationMatrixRowItem.create({ observation_matrix_row_item }).then(response => {
        TW.workbench.alert.create('Row item was successfully created.', 'notice')
        this.$emit('create', response.body)
      }).finally(() => {
        this.saving = false
      })
    }
  }
}
</script>
