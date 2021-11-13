<template>
  <div>
    <h3>Label</h3>
    <ul class="no_bullets">
      <li
        v-for="(item, index) in labelTypes"
        :key="index">
        <label>
          <input
            v-model="type"
            :value="item.value"
            type="radio"
          >
          {{ item.label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>

import {
  LABEL,
  LABEL_QR_CODE,
  LABEL_CODE_128
} from 'constants/index.js'

export default {
  props: {
    modelValue: {
      type: String,
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  computed: {
    type: {
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
      labelTypes: [
        {
          label: 'None',
          value: undefined
        },
        {
          label: 'Text',
          value: LABEL
        },
        {
          label: 'QR Code',
          value: LABEL_QR_CODE
        },
        {
          label: 'Barcode',
          value: LABEL_CODE_128
        }
      ]
    }
  }
}
</script>
