<template>
  <ul
    class="synonym-list"
    v-html="synonyms.join('\n')"
  />
</template>

<script setup>
defineProps({
  synonyms: {
    type: Array,
    default: () => []
  }
})
</script>
