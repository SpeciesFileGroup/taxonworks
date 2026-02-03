<template>
  <select v-model="value">
    <option
      v-for="type in TYPES"
      :key="type"
      :value="type"
      class="capitalize"
    >
      {{ type }}
    </option>
  </select>
</template>

<script setup>
const TYPES = ['exact', 'wildcard', 'any', 'no']

const value = defineModel({
  type: String,
  default: undefined
})
</script>
