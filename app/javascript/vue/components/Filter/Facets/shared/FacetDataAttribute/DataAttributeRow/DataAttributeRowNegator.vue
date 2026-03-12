<template>
  <select v-model="value">
    <option
      v-for="(value, key) in OPTIONS"
      :key="key"
      :value="value"
    >
      {{ key }}
    </option>
  </select>
</template>
<script setup>
const OPTIONS = {
  Is: false,
  'Is not': true
}

const value = defineModel({
  type: [Boolean, String],
  default: null
})
</script>
