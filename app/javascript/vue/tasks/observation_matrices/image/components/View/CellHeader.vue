<template>
  <div class="header-cell">
    <label
      class="header-label cursor-pointer ellipsis"
      :title="title">
      <tippy
        animation="scale"
        placement="bottom"
        size="small"
        arrow-size="small"
        inertia
        arrow
        content="Hide">
        <input
          type="checkbox"
          :value="index"
          v-model="hideColumn">
        {{ title }}
      </tippy>
    </label>
  </div>
</template>
<script>

import { Tippy } from 'vue-tippy'

export default {
  components: { Tippy },

  props: {
    title: {
      type: String,
      required: true
    },

    modelValue: {
      type: Array,
      required: true
    },

    index: {
      type: [String, Number],
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    hideColumn: {
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