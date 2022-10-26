<template>
  <div class="panel content">
    <h3 class="">
      {{ title }}
    </h3>
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
