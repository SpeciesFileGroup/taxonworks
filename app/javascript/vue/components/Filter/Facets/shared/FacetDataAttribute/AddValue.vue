<template>
  <div>
    <label>Value</label>
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
        <label>
          <input
            v-model="exact"
            type="checkbox"
          />
          Exact
        </label>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import VBtn from 'components/ui/VBtn/index.vue'

const emit = defineEmits('add')

const exact = ref()
const text = ref('')

function addValue() {
  emit('add', {
    text: text.value,
    exact: exact.value
  })

  text.value = ''
}
</script>
