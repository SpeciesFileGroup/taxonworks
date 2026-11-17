<template>
  <div class="panel content">
    <h3>Add images</h3>
    <template v-if="filterImages.length">
      <h4>From filter</h4>
      <SourceThumbnails
        :objects="filterImages"
        :object-type="IMAGE"
        noun="image"
        :placed-keys="placedKeys"
        @add="(payload) => emit('add', payload)"
      />
      <h4>From OTU</h4>
    </template>
    <OtuDepictions
      :placed-keys="placedKeys"
      @add="(payload) => emit('add', payload)"
    />
  </div>
</template>

<script setup>
import { IMAGE } from '@/constants'
import OtuDepictions from './OtuDepictions.vue'
import SourceThumbnails from './SourceThumbnails.vue'

defineProps({
  placedKeys: {
    type: Set,
    required: true
  },

  filterImages: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['add'])
</script>
