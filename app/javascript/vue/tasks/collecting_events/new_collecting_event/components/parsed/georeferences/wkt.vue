<template>
  <div>
    <button
      class="button normal-input button-default"
      @click="setModalView(true)">WKT coordinates</button>
    <modal-component
      v-if="show"
      @close="setModalView(false)">
      <h3 slot="header">Create WKT georeference</h3>
      <div slot="body">
        <div class="field label-above">
          <label>WKT data</label>
          <textarea
            class="full_width"
            rows="8"
            v-model="wkt"/>
        </div>
      </div>
      <div slot="footer">
        <button
          type="button"
          class="normal-input button button-submit"
          @click="createShape">
          Add
        </button>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import GeoreferenceTypes from '../../../const/georeferenceTypes'

export default {
  components: {
    ModalComponent
  },
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
