<template>
  <div
    class="full_width full_height panel"
    ref="root"
  >
    <SvgViewer
      v-if="width && height"
      :width="width"
      :height="height"
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
import { computed, ref, onMounted } from 'vue'

const store = useStore()
const imageStore = useImageStore()
const boardStore = useBoardStore()
const root = ref()
const width = ref()
const height = ref()

const layers = computed(() =>
  boardStore.layers.filter(({ collectionObjectId }) =>
    store.selectedId.includes(collectionObjectId)
  )
)

onMounted(() => {
  const size = root.value.getBoundingClientRect()
  const imageWidth = imageStore.image.width
  const imageHeight = imageStore.image.height
  const containerHeight = window.innerHeight - 250

  width.value = parseInt(size.width, 10)
  height.value = containerHeight
})
</script>
