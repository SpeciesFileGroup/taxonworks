<template>
  <div class="header-cell">
    <label
      class="header-label cursor-pointer ellipsis"
      :title="title"
    >
      <VTooltip content="Hide">
        <input
          type="checkbox"
          :value="index"
          v-model="hideColumn"
        />
        {{ title }}
      </VTooltip>
    </label>
  </div>
</template>
<script>
import VTooltip from '@/components/ui/VTooltip/VTooltip.vue'

export default {
  components: { VTooltip },

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
      get() {
        return this.modelValue
      },
      set(value) {
        this.$emit('update:modelValue', value)
      }
    }
  }
}
</script>
