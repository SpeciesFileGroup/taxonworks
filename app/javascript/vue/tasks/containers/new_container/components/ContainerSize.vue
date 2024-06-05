<template>
  <div class="horizontal-left-content gap-small margin-medium-top">
    <div class="field">
      <label class="d-block">X</label>
      <input
        type="number"
        :disabled="disabled"
        v-between-numbers="[1, 999]"
        v-model="size.x"
      />
    </div>
    <div class="field">
      <label class="d-block">Y</label>
      <input
        type="number"
        :disabled="disabled"
        v-between-numbers="[1, 999]"
        v-model="size.y"
      />
    </div>
    <div class="field">
      <label class="d-block">Z</label>
      <input
        type="number"
        :disabled="disabled"
        v-model="size.z"
      />
    </div>
  </div>
</template>

<script setup>
import { vBetweenNumbers } from '@/directives'

defineProps({
  disabled: {
    type: Boolean,
    default: false
  }
})

const size = defineModel({
  type: Object,
  required: true
})
</script>

<style scoped>
input[type='number'] {
  width: 60px;
}
</style>
