<template>
  <select v-model="value">
    <option
      v-for="(label, v) in COMBINATIONS"
      :key="v"
      :value="label"
    >
      {{ v }}
    </option>
  </select>
</template>

<script setup>
const COMBINATIONS = {
  AND: null,
  OR: true,
  'AND NOT': false
}

const value = defineModel({
  type: [Boolean, null],
  required: true
})
</script>
