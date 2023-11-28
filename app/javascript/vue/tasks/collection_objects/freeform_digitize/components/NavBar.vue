<template>
  <NavBar>
    <div
      v-if="imageStore.image"
      class="horizontal-left-content gap-small"
    >
      <div
        v-html="imageStore.image?.object_tag"
        class="margin-small-right"
      />
      <RadialAnnotator :global-id="imageStore.image.global_id" />
      <RadialNavigation :global-id="imageStore.image.global_id" />
    </div>
  </NavBar>
</template>

<script setup>
import NavBar from '@/components/layout/NavBar'
import useImageStore from '../store/image'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigation from '@/components/radials/navigation/radial.vue'

const imageStore = useImageStore()
</script>
