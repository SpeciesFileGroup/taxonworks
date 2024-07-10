<template>
  <BlockLayout>
    <template #header>
      <h3>Depictions</h3>
    </template>
    <template #body>
      <div>
        <DepictionRow
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
import DepictionRow from './DepictionRow.vue'

const props = defineProps({
  images: {
    type: Array,
    required: true
  }
})
</script>
