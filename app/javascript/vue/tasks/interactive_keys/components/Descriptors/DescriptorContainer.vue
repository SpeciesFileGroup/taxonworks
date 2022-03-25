<template>
  <div>
    <div class="display-block">
      <a
        @click="setModalView(true)"
        class="cursor-pointer">
        <slot name="title">
          {{ descriptor.name }}
        </slot>
      </a>
    </div>
    <slot />
    <depictions-container
      v-if="openModal"
      :characters="selected"
      :descriptor="descriptor"
      @close="setModalView(false)"
      @update="setValue"
    />
  </div>
</template>

<script>

import DepictionsContainer from './Depictions/DepictionsContainer'

export default {
  components: { DepictionsContainer },

  props: {
    descriptor: {
      type: Object,
      required: true
    },

    modelValue: {
      type: Object,
      default: () => []
    }
  },

  emits: ['update:modelValue'],

  computed: {
    selected: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  data () {
    return {
      openModal: false
    }
  },

  methods: {
    setModalView (value) {
      this.openModal = value
    },

    setValue (value) {
      this.selected[this.descriptor.id] = value
    }
  }
}
</script>
