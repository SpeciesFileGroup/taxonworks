<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="setModalView(true)">
      Add new label
    </button>
    <modal-component
      v-if="showModal"
      @close="setModalView(false)">
      <template #header>
        <h3>Label form</h3>
      </template>
      <template #body>
        <div>
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
              disabled
              v-model="label.style">
          </div>
          <div class="field">
            <ul class="no_bullets">
              <li v-for="type in types">
                <label>
                  <input
                    type="radio"
                    :value="type.value"
                    v-model="label.type">
                  {{ type.label }}
                </label>
              </li>
            </ul>
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
      </template>
      <template #footer>
        <button
          type="button"
          class="button normal-input button-submit"
          :disabled="!label.text.length"
          @click="save">Save</button>
      </template>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal.vue'
import Types from '../const/type'

export default {
  components: { ModalComponent },

  props: {
    modelValue: {
      type: Object,
      default: () => ({})
    }
  },

  emits: [
    'update:modelValue',
    'save'
  ],

  computed: {
    label: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  data () {
    return {
      showModal: false,
      types: Types
    }
  },

  watch: {
    label: {
      handler (newVal, oldVar) {
        if (newVal?.id && oldVar?.id !== newVal?.id) {
          this.showModal = true
        }
      },
      immediate: true
    }
  },

  methods: {
    save () {
      this.$emit('save', this.label)
      this.label = this.setModalView(false)
    },

    newLabel () {
      return {
        text: '',
        total: 0,
        style: '',
        type: 'Label',
        is_printed: false,
        is_copy_edited: false
      }
    },

    setModalView (value) {
      this.label = !value ? undefined : this.newLabel()
      this.showModal = value
    }
  }
}
</script>
