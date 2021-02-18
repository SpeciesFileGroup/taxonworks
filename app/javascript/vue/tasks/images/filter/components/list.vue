<template>
  <div class="panel flex-wrap-row padding-small">
    <image-component
      v-for="image in list"
      class="margin-small"
      :key="image.id"
      :image="image"/>
  </div>
</template>

<script>

import ImageComponent from './image.vue'

export default {
  components: {
    ImageComponent
  },
  props: {
    list: {
      type: Array,
      required: true
    }
  }
}
</script>
