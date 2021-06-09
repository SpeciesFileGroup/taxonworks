<template>
  <div class="panel basic-information">
    <div class="header">
      <h3>Type</h3>
    </div>
    <div class="body">
      <ul class="no_bullets">
        <li
          v-for="(label, key) in types"
          :key="key">
          <label>
            <input
              :disabled="descriptorId"
              type="radio"
              v-model="selection"
              :value="key"
              name="type-descriptor">
            {{ label }}
          </label>
        </li>
      </ul>
    </div>
  </div>
</template>
<script>

import TYPES from '../../const/types'

export default {
  props: {
    modelValue: {
      type: String,
      default: undefined
    },
    descriptorId: {
      type: [String, Number],
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  computed: {
    selection: {
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
      types: TYPES()
    }
  }
}
</script>
