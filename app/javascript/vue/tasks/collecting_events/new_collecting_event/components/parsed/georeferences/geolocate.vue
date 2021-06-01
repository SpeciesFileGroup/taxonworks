<template>
  <div>
    <button
      class="button normal-input button-default"
      @click="setModalView(true)">GEOLocate</button>
    <modal-component
      v-if="show"
      @close="setModalView(false)">
      <h3 slot="header">GEOLocate</h3>
      <div slot="body">
        <div class="field">
          <label>Coordinates:</label>
          <textarea
            class="full_width"
            rows="5"
            v-model="iframe_response">
          </textarea>
        </div>
      </div>
      <div slot="footer">
        <button
          type="button"
          class="normal-input button button-submit"
          :disabled="!validateFields"
          @click="createShape">
          Add
        </button>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal'
import GeoreferenceTypes from '../../../const/georeferenceTypes'

export default {
  components: {
    ModalComponent
  },
  computed: {
    validateFields () {
      return this.iframe_response
    }
  },
  data () {
    return {
      show: false,
      iframe_response: undefined
    }
  },
  methods: {
    createShape () {
      this.$emit('create', {
        tmpId: Math.random().toString(36).substr(2, 5),
        iframe_response: this.iframe_response,
        type: GeoreferenceTypes.Geolocate
      })
      this.iframe_response = undefined
      this.show = false
    },
    resetShape () {
      this.iframe_response = undefined
    },
    setModalView (value) {
      this.resetShape()
      this.show = value
    }
  }
}
</script>
