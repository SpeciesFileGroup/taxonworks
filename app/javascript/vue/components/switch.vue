<template>
  <div class="switch-radio">
    <template
      v-for="(item, index) in options.concat(addOption)">
      <template
        v-if="filter(item)">
        <input
          @click="emitEvent(index)"
          :value="useIndex ? index : item"
          :key="index"
          v-model="inputValue"
          :id="`switch-${name}-${index}`"
          :name="`switch-${name}-options`"
          type="radio"
          :checked="item === (useIndex ? index : modelValue)"
          class="normal-input button-active"
        >
        <label
          :for="`switch-${name}-${index}`"
          :key="`${index}a`">{{ item }}
        </label>
      </template>
    </template>
  </div>
</template>
<script>
export default {
  props: {
    options: {
      type: Array,
      required: true
    },

    modelValue: {
      type: [String, Number],
      default: undefined
    },

    addOption: {
      type: Array,
      required: false,
      default: () => []
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
    }
  },

  emits: [
    'update:modelValue',
    'index'
  ],

  computed: {
    inputValue: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  methods: {
    emitEvent (index) {
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
