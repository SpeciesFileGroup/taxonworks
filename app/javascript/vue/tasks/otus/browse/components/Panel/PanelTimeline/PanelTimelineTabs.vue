<template>
  <div class="switch-radio separate-top separate-bottom">
    <template
      v-for="(item, index) in tabs"
      :key="item.label"
    >
      <input
        v-model="selected"
        :id="`switch-filter-nomenclature-${index}`"
        name="switch-filter-nomenclature-options"
        type="radio"
        class="normal-input button-active"
        :value="item"
      />
      <label :for="`switch-filter-nomenclature-${index}`">
        {{ item.label }}
      </label>
    </template>
  </div>
</template>

<script setup>
defineProps({
  tabs: {
    type: Array,
    required: true
  }
})

const selected = defineModel({
  type: Object,
  required: true
})
</script>
