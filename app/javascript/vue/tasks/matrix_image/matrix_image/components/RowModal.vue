<template>
  <modal-component @close="$emit('close', true)">
    <spinner-component v-if="saving"/>
    <h3 slot="header">Create new row</h3>
    <div slot="body">
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
    </div>
  </modal-component>
</template>

<script>

import ModalComponent from 'components/modal.vue'
import OtuPicker from 'components/otu/otu_picker/otu_picker.vue'
import SpinnerComponent from 'components/spinner'

import { CreateRow } from '../request/resources'

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
  data() {
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
    createRow(object) {
      let data = {
        observation_matrix_id: this.matrixId,
        type: this.type.type,
        [this.type.label === 'Otu' ? 'otu_id' : 'collection_object_id']: object.id
      }
      this.saving = true
      CreateRow(data).then(response => {
        TW.workbench.alert.create('Row item was successfully created.', 'notice')
        this.$emit('create', response.body)
        this.saving = false
      }, () => {
        this.saving = false
      })
    }
  }
}
</script>
