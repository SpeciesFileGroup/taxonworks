<template>
  <div class="label-above">
    <select v-model="value">
      <option disabled>Match</option>
      <option
        v-for="(label, v) in COMBINATIONS"
        :key="label"
        :value="v"
      >
        {{ label }}
      </option>
    </select>
  </div>
</template>

<script setup>
const COMBINATIONS = {
  null: 'AND',
  true: 'OR',
  false: 'AND NOT'
}

const value = defineModel({
  type: [Boolean, null],
  required: true
})
</script>
