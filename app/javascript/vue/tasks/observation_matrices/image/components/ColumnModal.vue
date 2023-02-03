<template>
  <modal-component @close="$emit('close', true)">
    <template #header>
      <h3>Create new column</h3>
    </template>
    <template #body>
      <div class="separate-top">
        <div class="field">
          <label>Name</label>
          <br>
          <input
            v-model="descriptor.name"
            class="full_width"
            type="text"
          >
        </div>
        <div class="field">
          <label>Description</label>
          <br>
          <textarea
            class="full_width"
            v-model="descriptor.description"
            rows="5"
          />
        </div>
        <button
          type="button"
          class="button normal-input button-submit"
          :disabled="!validateFields"
          @click="createColumn"
        >
          Create
        </button>
      </div>
    </template>
  </modal-component>
</template>

<script>

import ModalComponent from 'components/ui/Modal.vue'
import { ActionNames } from '../store/actions/actions'

export default {
  components: {
    ModalComponent
  },

  emits: ['close'],

  computed: {
    validateFields () {
      return this.descriptor.name.length
    }
  },

  data () {
    return {
      descriptor: {
        name: '',
        description: ''
      }
    }
  },

  methods: {
    createColumn () {
      this.$store.dispatch(ActionNames.CreateNewColumn, {
        descriptorName: this.descriptor.name,
        description: this.descriptor.description
      }).then(_ => this.$emit('close'))
    }
  }
}
</script>
