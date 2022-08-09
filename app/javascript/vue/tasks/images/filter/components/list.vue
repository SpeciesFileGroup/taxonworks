<template>
  <div class="panel flex-wrap-row padding-small">
    <image-component
      v-for="image in list"
      v-model="imageIds"
      class="margin-small"
      :key="image.id"
      :image="image"/>
  </div>
</template>

<script>

import ImageComponent from './image.vue'

export default {
  components: { ImageComponent },

  props: {
    list: {
      type: Array,
      required: true
    },

    modelValue: {
      type: Array,
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    imageIds: {
      get () {
        return this.modelValue
      },

      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  }
}
</script>
