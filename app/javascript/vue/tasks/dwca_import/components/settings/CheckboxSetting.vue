<template>
  <div class="label-above">
    <label>
      <input
        type="checkbox"
        v-model="inputValue"
      />
      {{ label }}
    </label>
  </div>
</template>

<script setup>
import { useImportSetting } from './useImportSetting.js'

const props = defineProps({
  label: {
    type: String,
    required: true
  },

  property: {
    type: String,
    required: true
  }
})

const inputValue = useImportSetting(props.property)
</script>
