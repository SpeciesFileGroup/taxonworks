<template>
  <div>
    <div class="flex-separate flex-start capitalize">
      <span>{{ index }} - {{ pattern.mode }}</span>
    </div>

    <div class="horizontal-left-content gap-small">
      <div>
        <input
          type="text"
          v-model="pattern.match"
          placeholder="Find"
        />
      </div>
      <div v-if="pattern.mode === PATTERN_TYPES.Replace">
        <input
          type="text"
          placeholder="Replace"
          v-model="pattern.value"
        />
      </div>
      <div v-else-if="pattern.mode === PATTERN_TYPES.Extract">
        <input
          type="text"
          placeholder="Apply to end"
          v-model="pattern.value"
        />
      </div>

      <VBtn
        color="primary"
        circle
        @click="emit('remove')"
      >
        <VIcon
          name="trash"
          x-small
        />
      </VBtn>
    </div>
    <div v-if="pattern.mode === PATTERN_TYPES.Extract">
      <label>
        <input
          type="checkbox"
          v-model="pattern.emptyOnly"
        />
        Empty only
      </label>
    </div>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { PATTERN_TYPES } from '../../constants'

defineProps({
  index: {
    type: Number,
    required: true
  }
})

const pattern = defineModel({
  type: Object,
  required: true
})

const emit = defineEmits(['remove'])
</script>
