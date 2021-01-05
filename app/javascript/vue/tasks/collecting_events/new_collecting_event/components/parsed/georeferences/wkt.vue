<template>
  <div>
    <button
      class="button normal-input button-default"
      @click="openModal">WTK coordinates</button>
    <modal-component
      v-if="show"
      @close="show = false">
      <h3 slot="header">Create WTK georeference</h3>
      <div slot="body">
        <div class="field label-above">
          <label>WTK data</label>
          <textarea
            class="full_width"
            rows="8"
            v-model="wtk"/>
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
      wtk: undefined
    }
  },
  methods: {
    createShape () {
      this.$emit('create', {
        tmpId: Math.random().toString(36).substr(2, 5),
        wkt: this.wtk,
        type: GeoreferenceTypes.Wkt
      })
      this.show = false
    },
    resetShape () {
      return {
        wtk: undefined
      }
    },
    openModal () {
      this.show = true
    }
  }
}
</script>
