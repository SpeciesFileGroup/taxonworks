<template>
  <BlockLayout>
    <template #header>
      <h3>Uploaded images</h3>
    </template>
    <template #body>
      <div class="flex-wrap-row full_width">
        <h3
          v-if="!images.length"
          class="full_width center_text"
        >
          <span class="center_text full_width">No images uploaded</span>
        </h3>
        <ImageViewer
          v-for="image in images"
          :key="image.id"
          :image="image"
        />
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import ImageViewer from '@/tasks/images/filter/components/image.vue'

const images = defineModel({
  type: Array,
  required: true
})
</script>
