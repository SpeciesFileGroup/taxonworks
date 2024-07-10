<template>
  <BlockLayout>
    <template #header>
      <h3>Images</h3>
    </template>
    <template #body>
      <ImageDropzone v-model="images" />
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import ImageDropzone from './ImageDropzone.vue'

const images = defineModel({
  type: Array,
  required: true
})
</script>
