<template>
  <div class="panel panel__content">
    <h2 class="panel__title">
      {{ title }}
    </h2>
    <hr>
    <slot />
  </div>
</template>

<script setup>
defineProps({
  title: {
    type: String,
    required: true
  }
})
</script>
