<template>
  <div>
    <h3>Label</h3>
    <ul class="no_bullets">
      <li
        v-for="(item, index) in LABEL_TYPES"
        :key="index"
      >
        <label>
          <input
            v-model="type"
            :value="item.value"
            type="radio"
          />
          {{ item.label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { LABEL, LABEL_QR_CODE, LABEL_CODE_128 } from '@/constants/index.js'

const LABEL_TYPES = [
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

const type = defineModel({
  type: String,
  default: undefined
})
</script>
