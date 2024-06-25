<template>
  <div>
    <button
      class="button normal-input button-default"
      @click="setModalView(true)"
    >
      WKT coordinates
    </button>
    <modal-component
      v-if="show"
      @close="setModalView(false)"
    >
      <template #header>
        <slot name="header"><h3>Create WKT georeference</h3></slot>
      </template>
      <template #body>
        <div class="field label-above">
          <label>WKT data</label>
          <textarea
            class="full_width"
            rows="8"
            v-model="wkt"
          />
        </div>
      </template>
      <template #footer>
        <button
          type="button"
          class="normal-input button button-submit"
          @click="createShape"
        >
          Add
        </button>
      </template>
    </modal-component>
  </div>
</template>

<script>
import ModalComponent from '@/components/ui/Modal'
import { GEOREFERENCE_WKT } from '@/constants/index.js'
import { props } from 'vue-handy-scroll'

export default {
  components: { ModalComponent },

  props: {
    type: {
      type: String,
      default: GEOREFERENCE_WKT
    },
    id_key: {
      type: String,
      default: 'tmpId'
    },
    id_generator: {
      type: Function,
      default: () => Math.random().toString(36).substr(2, 5)
    }
  },

  emits: ['create'],

  data() {
    return {
      show: false,
      wkt: undefined
    }
  },

  methods: {
    createShape() {
      this.$emit('create', {
        [this.id_key]: (this.id_generator)(),
        wkt: this.wkt,
        type: this.type
      })
      this.show = false
    },

    resetShape() {
      this.wkt = undefined
    },

    setModalView(value) {
      this.resetShape()
      this.show = value
    }
  }
}
</script>
