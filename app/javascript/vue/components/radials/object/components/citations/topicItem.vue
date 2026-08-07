<template>
  <button
    :style="{
      borderRightColor: topic.css_color,
      borderRightWidth: '4px',
      borderRightStyle: 'solid'
    }"
    @click="sendTopic(topic.id)"
    type="button"
    class="normal-input button tag_button btn-data"
  >
    {{ topic.name }}
  </button>
</template>

<script setup>
const props = defineProps({
  topic: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['select'])

function sendTopic() {
  emit('select', props.topic)
}
</script>
