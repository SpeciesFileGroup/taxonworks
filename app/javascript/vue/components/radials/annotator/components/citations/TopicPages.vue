<template>
  <input
    :value="topic.pages"
    type="text"
    @change="updatePage"
  />
</template>

<script setup>
import { computed } from 'vue'
const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  },

  citationId: {
    type: [String, Number],
    required: true
  }
})

const emit = defineEmits(['update:modelValue', 'update'])

const topic = computed({
  get() {
    return props.modelValue
  },
  set(value) {
    emit('update:modelValue', value)
  }
})

function updatePage(e) {
  const value = e.target.value
  const payload = {
    id: props.citationId,
    citation_topics_attributes: [
      {
        id: topic.value.id,
        pages: value
      }
    ]
  }

  emit('update', payload)
}
</script>
