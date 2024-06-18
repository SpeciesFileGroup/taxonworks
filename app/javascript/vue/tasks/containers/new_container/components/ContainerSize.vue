<template>
  <div class="horizontal-left-content gap-small margin-medium-top">
    <div
      v-for="axis in AXES"
      :key="axis"
      class="field"
    >
      <label class="d-block capitalize">{{ axis }}</label>
      <input
        type="number"
        :disabled="disabled"
        v-between-numbers="[1, 999]"
        v-model="size[axis]"
        @change="() => emit('change', true)"
      />
    </div>
  </div>
</template>

<script setup>
import { vBetweenNumbers } from '@/directives'

const AXES = ['x', 'y', 'z']

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

const emit = defineEmits(['change'])
</script>

<style scoped>
input[type='number'] {
  width: 60px;
}
</style>
