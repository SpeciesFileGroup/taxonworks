<template>
  <VTabs
    class="justify-center news-categories"
    :tabs="types"
    v-model="currentType"
  />
</template>

<script setup>
import VTabs from './Tabs.vue'

defineProps({
  types: {
    type: Array,
    required: true
  }
})

const currentType = defineModel({
  type: String,
  default: 'All'
})
</script>
