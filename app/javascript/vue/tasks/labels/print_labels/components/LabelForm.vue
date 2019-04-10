<template>
  <modal-component 
    v-if="showModal"
    @close="$emit('close', false)">
    <h3 slot="header">Label form</h3>
    <div slot="body">
      <div class="field">
        <label>Text</label>
        <br>
        <textarea
          class="full_width"
          rows="10"
          type="text"
          v-model="label.text"/>
      </div>
      <div class="field">
        <label>Total</label>
        <br>
        <input
          type="number"
          class="full_width"
          v-model="label.total">
      </div>
      <div class="field">
        <label>Style</label>
        <br>
        <input
          type="text"
          class="full_width"
          v-model="label.style">
      </div>
      <div class="field">
        <label>
          <input
            type="checkbox"
            v-model="label.is_copy_edited">
          Is copy edited
        </label>
      </div>
      <div class="field">
        <label>
          <input
            type="checkbox"
            v-model="label.is_printed">
          Is printed
        </label>
      </div>
    </div>
    <div slot="footer">
      <button
        type="button"
        class="button normal-input button-submit"
        :disabled="!label.text.length"
        @click="save">Save</button>
    </div>
  </modal-component>
</template>

<script>
import ModalComponent from 'components/modal.vue'
export default {
  components: {
    ModalComponent
  },
  props: {
    showModal: {
      type: Boolean,
      default: false
    },
    value: {
      type: Object,
      default: () => { return {} }
    }
  },
  data() {
    return {
      label: this.newLabel()
    }
  },
  watch: {
    value:{ 
      handler(newVal) {
        if(Object.keys(newVal).length)
          this.label = Object.assign({}, newVal)
      },
      immediate: true
    }
  },
  methods: {
    save() {
      this.$emit('save', this.label)
      this.label = this.newLabel()
    },
    newLabel() {
      return {
        text: '',
        total: 0,
        style: '',
        is_printed: false,
        is_copy_edited: false
      }
    }
  }
}
</script>
