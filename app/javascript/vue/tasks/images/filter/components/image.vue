<template>
  <div
    style="background-color: black; width: 100px; height: 100px"
    class="depiction-thumb-container horizontal-center-content middle position-relative">
    <img
      class="cursor-pointer"
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
    <modal-component
      v-if="showModal"
      @close="setModalView(false)">
      <h3 slot="header">Image</h3>
      <div
        slot="body"
        class="horizontal-left-content align-start">
        <div class="full_width">
          <img
            class="img-maxsize"
            :src="image.image_file_url"
            :height="image.height"
            :width="image.width">
        </div>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import PinComponent from 'components/pin'

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
