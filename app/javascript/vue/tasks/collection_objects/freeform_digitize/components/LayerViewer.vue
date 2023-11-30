<template>
  <div class="full_width full_height">
    <SvgViewer
      :width="imageStore.image.width"
      :height="imageStore.image.height"
      :groups="layers"
      :image="{
        url: imageStore.image.image_file_url,
        width: imageStore.image.width,
        height: imageStore.image.height
      }"
    />
  </div>
</template>

<script setup>
import SvgViewer from '@/components/Svg/SvgViewer.vue'
import useImageStore from '../store/image'
import useBoardStore from '../store/board'
import useStore from '../store/store'
import { computed } from 'vue'

const store = useStore()
const imageStore = useImageStore()
const boardStore = useBoardStore()

const layers = computed(() =>
  boardStore.layers
    .filter(({ collectionObjectId }) =>
      store.selectedId.includes(collectionObjectId)
    )
    .map((l) => l.svg)
)
</script>
