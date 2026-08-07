<template>
  <div>
    <label>{{ label }}</label>
    <div class="field">
      <textarea
        v-model="text"
        class="full_width"
        rows="5"
      />
      <div class="flex-separate middle">
        <div class="horizontal-left-content middle gap-small">
          <VBtn
            color="primary"
            medium
            :disabled="!text.length"
            @click="() => addValue()"
          >
            Add
          </VBtn>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'

defineProps({
  label: {
    type: String,
    default: 'Value'
  }
})

const emit = defineEmits('add')

const text = ref('')

function addValue() {
  emit('add', {
    text: text.value,
    exact: false
  })

  text.value = ''
}
</script>
