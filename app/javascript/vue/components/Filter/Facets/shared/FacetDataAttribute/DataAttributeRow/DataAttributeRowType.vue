<template>
  <div class="label-above">
    <select v-model="value">
      <option disabled>Match</option>
      <option
        v-for="type in TYPES"
        :key="type"
        :value="type"
        class="capitalize"
      >
        {{ type }}
      </option>
    </select>
  </div>
</template>

<script setup>
const TYPES = ['exact', 'wildcard', 'any', 'no']

const value = defineModel({
  type: String,
  default: undefined
})
</script>
