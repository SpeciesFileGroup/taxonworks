<template>
  <div>
    <h3 class="panel__subtitle">
      {{ title }}
    </h3>
    <span>{{ text }}</span>
  </div>
</template>

<script setup>
defineProps({
  title: {
    type: String,
    required: true
  },

  text: {
    type: String,
    required: true
  }
})
</script>
