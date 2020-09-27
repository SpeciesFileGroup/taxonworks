<template>
  <modal-component @close="$emit('close', true)">
    <spinner-component v-if="saving"/>
    <h3 slot="header">Create new column</h3>
    <div slot="body">
      <div
        class="separate-top">
        <div class="field">
          <label>Name</label>
          <br>
          <input
            v-model="descriptor.name"
            class="full_width"
            type="text">
        </div>
        <div class="field">
          <label>Description</label>
          <br>
          <textarea
            class="full_width"
            v-model="descriptor.description_name" />
        </div>
        <button
          type="button"
          class="button normal-input button-submit"
          :disabled="!validateFields"
          @click="createColumn">
          Create
        </button>
      </div>
    </div>
  </modal-component>
</template>

<script>

import ModalComponent from 'components/modal.vue'
import SpinnerComponent from 'components/spinner'

import { CreateColumn, CreateDescriptor } from '../request/resources'

export default {
  components: {
    ModalComponent,
    SpinnerComponent
  },
  props: {
    matrixId: {
      type: [Number, String],
      required: true
    }
  },
  computed: {
    validateFields() {
      return this.descriptor.name.length
    }
  },
  data() {
    return {
      descriptor: {
        name: '',
        description_name: '',
        type: 'Descriptor::Media'
      },
      saving: false
    }
  },
  methods: {
    createColumn() {
      this.saving = true

      CreateDescriptor(this.descriptor).then(responseDescriptor => {
        let data = {
          observation_matrix_id: this.matrixId,
          descriptor_id: responseDescriptor.body.id,
          type: 'ObservationMatrixColumnItem::Single::Descriptor'
        }
        CreateColumn(data).then(response => {
          response.body.descriptor = responseDescriptor.body
          TW.workbench.alert.create('Column item was successfully created.', 'notice')
          this.$emit('create', response.body)
          this.saving = false
        }, () => {
          this.saving = false
        })
      }, () => {
        this.saving = false
      })
    }
  }
}
</script>
