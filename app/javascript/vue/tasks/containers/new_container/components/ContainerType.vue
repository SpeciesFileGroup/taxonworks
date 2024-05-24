<template>
  <div class="field">
    <label class="d-block">Type</label>
    <select v-model="type">
      <option
        v-for="value in CONTAINER_TYPES"
        :key="value"
        :value="value"
      >
        {{ value.split('::')[1] }}
      </option>
    </select>
  </div>
</template>

<script setup>
import * as CONTAINER_TYPES from '@/constants/containerTypes.js'

const type = defineModel({
  type: String,
  default: undefined
})
</script>
