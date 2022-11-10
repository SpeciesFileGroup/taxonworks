<template>
  <div>
    <h3 class="panel__subtitle">
      {{ title }}
    </h3>
    <pre class="break_words_pre">{{ text }}</pre>
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
