<template>
  <div class="field">
    <label class="d-block">Model</label>
    <select v-model="modelSelected">
      <option
        :value="null"
        disabled
      >
        None
      </option>
      <option
        v-for="model in types"
        :key="model"
        :value="model"
      >
        {{ model }}
      </option>
    </select>
  </div>
</template>

<script setup>
defineProps({
  types: {
    type: Array,
    required: true
  }
})

const modelSelected = defineModel({
  type: String,
  default: null
})
</script>
