<template>
  <div class="switch-radio">
    <template
      v-for="(item, index) in options"
      :key="index"
    >
      <template v-if="filter(item)">
        <input
          @click="emitEvent(index)"
          :value="useIndex ? index : item"
          v-model="inputValue"
          :id="`switch-${name}-${index}`"
          :name="`switch-${name}-options`"
          type="radio"
          class="normal-input button-active"
        />
        <label
          :for="`switch-${name}-${index}`"
          :style="fullWidth && { width: '100%' }"
        >
          {{ item }}
        </label>
      </template>
    </template>
  </div>
</template>
<script>
export default {
  props: {
    options: {
      type: [Array, Object],
      required: true
    },

    modelValue: {
      type: [String, Number],
      default: undefined
    },

    name: {
      type: String,
      required: false,
      default: () => Math.random().toString(36).substr(2, 5)
    },

    filter: {
      type: Function,
      default: () => true
    },

    useIndex: {
      type: Boolean,
      required: false
    },

    fullWidth: {
      type: Boolean,
      default: false
    }
  },

  emits: ['update:modelValue', 'index'],

  computed: {
    inputValue: {
      get() {
        return this.modelValue
      },
      set(value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  methods: {
    emitEvent(index) {
      this.$emit('index', index)
    }
  }
}
</script>
<style scoped>
label::first-letter {
  text-transform: capitalize;
}
</style>
