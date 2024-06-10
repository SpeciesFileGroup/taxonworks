<template>
  <div class="field">
    <label class="d-block">Type</label>
    <select v-model="type">
      <option
        v-for="item in types"
        :key="item.type"
        :value="item"
      >
        {{ item.name }}
      </option>
    </select>
  </div>
</template>

<script setup>
defineProps({
  types: {
    type: Array,
    default: () => []
  }
})

const type = defineModel({
  type: Object,
  default: undefined
})
</script>
