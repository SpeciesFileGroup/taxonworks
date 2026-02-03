# @param data_attribute_value_negator # @return Array[Boolean] # True to negate
the value_type in this row # False or nil - ignore

<template>
  <div>
    <select v-model="value">
      <option
        v-for="(label, v) in OPTIONS"
        :key="label"
        :value="v"
      >
        {{ label }}
      </option>
    </select>
  </div>
</template>
<script setup>
const OPTIONS = {
  null: 'Is',
  true: 'Is not'
}

const value = defineModel({
  type: [Boolean, null],
  default: null
})
</script>
