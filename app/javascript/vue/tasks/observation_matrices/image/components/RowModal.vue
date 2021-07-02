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
          :key="item.type">
          <label>
            <input
              type="radio"
              v-model="type"
              :value="item">
            {{ item.label }}
          </label>
        </li>
      </ul>
      <div
        class="separate-top"
        v-if="type.label === 'Otu'">
        <otu-picker @getItem="createRow"/>
      </div>
    </template>
  </modal-component>
</template>

<script>

import ModalComponent from 'components/ui/Modal.vue'
import OtuPicker from 'components/otu/otu_picker/otu_picker.vue'
import SpinnerComponent from 'components/spinner'
import { ObservationMatrixRowItem } from 'routes/endpoints'

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
        {
          label: 'Otu',
          type: 'ObservationMatrixRowItem::Single::Otu'
        },
        {
          label: 'Collection object',
          type: 'ObservationMatrixRowItem::Single::CollectionObject'
        }
      ],
      type: {
        label: 'Otu',
        type: 'ObservationMatrixRowItem::Single::Otu'
      },
      saving: false
    }
  },

  methods: {
    createRow (object) {
      const observation_matrix_row_item = {
        observation_matrix_id: this.matrixId,
        type: this.type.type,
        [this.type.label === 'Otu' ? 'otu_id' : 'collection_object_id']: object.id
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
