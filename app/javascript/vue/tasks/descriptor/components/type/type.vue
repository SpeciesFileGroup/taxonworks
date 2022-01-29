<template>
  <block-layout>
    <template #header>
      <h3>Type</h3>
    </template>
    <template #body>
      <ul class="no_bullets">
        <li
          v-for="(label, key) in TYPES"
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
    </template>
  </block-layout>
</template>
<script>

import BlockLayout from 'components/layout/BlockLayout.vue'
import TYPES from '../../const/types'

export default {
  components: { BlockLayout },

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
      TYPES
    }
  }
}
</script>
