<template>
  <BlockLayout>
    <template #header>
      <h3>Depictions</h3>
    </template>
    <template #body>
      <div class="flex-col">
        <h3 v-if="!images.length">
          <span class="center_text full_width">No images uploaded</span>
        </h3>
        <DepictionRow
          v-for="(image, index) in images"
          :key="image.id"
          :image="image"
          class="new-filename-depiction-row"
          @remove="() => images.splice(index, 1)"
        />
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import DepictionRow from './DepictionRow.vue'

const images = defineModel({
  type: Array,
  required: true
})
</script>

<style scoped>
.new-filename-depiction-row {
  border-bottom: 2px solid var(--color-border);
  padding: 1rem 0;
}

.new-filename-depiction-row:first-child {
  padding-top: 0;
}

.new-filename-depiction-row:last-child {
  border-bottom: none;
}
</style>
