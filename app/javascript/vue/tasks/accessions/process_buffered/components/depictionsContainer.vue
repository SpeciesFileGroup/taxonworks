<template>
  <div class="horizontal-left-content align-start">
    <div>
      <div v-for="depiction in depictions">
        <div>
          <img
            :class="{ 'selected-depiction': (selectedDepiction && selectedDepiction.id === depiction.id) }"
            class="cursor-pointer depiction-image"
            :src="depiction.image.alternatives.thumb.image_file_url"
            @click="selectDepiction(depiction)">
        </div>
      </div>
    </div>
    <div v-if="selectedDepiction && selectedDepiction.hasOwnProperty('sqed_depiction')">
      <div
        v-for="image in selectedDepiction.sqed_depiction.image_sections"
        :key="image.small_image">
        <img
          :class="{ 'selected-depiction': (selectedImage && selectedImage.small_image === image.small_image) }"
          class="cursor-pointer depiction-image"
          :src="image.small_image"
          @click="selectImage(image)">
      </div>
    </div>
  </div>
</template>
<script>

import { GetterNames } from '../store/getters/getters'

export default {
  computed: {
    depictions () {
      return this.$store.getters[GetterNames.GetSqedDepictions]
    }
  },
  data () {
    return {
      selectedDepiction: undefined,
      selectedImage: undefined
    }
  },
  methods: {
    selectDepiction (depiction) {
      this.selectedDepiction = depiction
      this.$emit('selectedDepiction', depiction)
    },
    selectImage (image) {
      this.selectedImage = image
      this.$emit('selectedImage', image)
    }
  }
}
</script>
<style scoped>
  .depiction-image {
    border: 1px solid transparent;
  }
  .selected-depiction {
    border: 1px solid black;
  }
</style>
