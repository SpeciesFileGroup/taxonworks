<template>
  <BlockLayout>
    <template #header>
      <h3>Images</h3>
    </template>
    <template #body>
      <ImageDropzone
        v-model="images"
        v-model:error="error"
      />
      <ImageErrorList
        v-if="error.length"
        class="margin-medium-top"
        v-model="error"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import ImageDropzone from './ImageDropzone.vue'
import ImageErrorList from './ImageErrorList.vue'

const images = defineModel({
  type: Array,
  required: true
})

const error = defineModel('error', {
  type: Array,
  required: true
})
</script>
