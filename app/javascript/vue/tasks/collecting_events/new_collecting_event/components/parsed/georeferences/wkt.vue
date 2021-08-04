<template>
  <div>
    <button
      class="button normal-input button-default"
      @click="setModalView(true)">WKT coordinates</button>
    <modal-component
      v-if="show"
      @close="setModalView(false)">
      <template #header>
        <h3>Create WKT georeference</h3>
      </template>
      <template #body>
        <div class="field label-above">
          <label>WKT data</label>
          <textarea
            class="full_width"
            rows="8"
            v-model="wkt"/>
        </div>
      </template>
      <template #footer>
        <button
          type="button"
          class="normal-input button button-submit"
          @click="createShape">
          Add
        </button>
      </template>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal'
import GeoreferenceTypes from '../../../const/georeferenceTypes'

export default {
  components: { ModalComponent },

  emits: ['create'],

  data () {
    return {
      show: false,
      wkt: undefined
    }
  },

  methods: {
    createShape () {
      this.$emit('create', {
        tmpId: Math.random().toString(36).substr(2, 5),
        wkt: this.wkt,
        type: GeoreferenceTypes.Wkt
      })
      this.show = false
    },

    resetShape () {
      this.wkt = undefined
    },

    setModalView (value) {
      this.resetShape()
      this.show = value
    }
  }
}
</script>
