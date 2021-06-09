<template>
  <div class="depiction-thumb-container">
    <modal-component
      v-if="showModal"
      @close="setModalView(false)">
      <h3 slot="header">Image</h3>
      <div
        slot="body">
        <img
          class="img-maxsize"
          :src="image.image_file_url">
      </div>
    </modal-component>
    <div
      class="depiction-thumb-container depiction-thumb-image horizontal-center-content middle position-relative">
      <img
        class="img-thumb"
        :src="image.alternatives.thumb.image_file_url"
        @click="setModalView(true)">
      <pin-component
        class="position-absolute"
        :style="{
          right: '4px',
          bottom: '4px'
        }"
        :object-id="image.id"
        type="Image"/>
    </div>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal'
import PinComponent from 'components/ui/Pinboard/VPin.vue'

export default {
  components: {
    ModalComponent,
    PinComponent
  },
  props: {
    image: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      showModal: false
    }
  },
  methods: {
    setModalView(value) {
      this.showModal = value
    }
  }
}
</script>
