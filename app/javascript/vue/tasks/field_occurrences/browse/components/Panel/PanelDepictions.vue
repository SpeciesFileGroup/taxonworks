<template>
  <PanelContainer title="Depictions">
    <div class="flex-wrap-row depictions-list">
      <ImageViewer
        v-for="depiction in store.depictions"
        :key="depiction.id"
        :depiction="depiction"
      />
    </div>
  </PanelContainer>
</template>

<script setup>
import { watch } from 'vue'
import useDepictionStore from '../../store/depictions.js'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer'
import PanelContainer from './PanelContainer.vue'

const props = defineProps({
  objectId: {
    type: [String, undefined],
    required: true
  },

  objectType: {
    type: [String, undefined],
    required: true
  }
})

const store = useDepictionStore()

watch(
  () => props.objectId,
  (id) => {
    store.$reset()

    if (id) {
      store.load({
        objectId: props.objectId,
        objectType: props.objectType
      })
    }
  }
)
</script>

<style scoped>
.depictions-list {
  max-height: 300px;
  overflow-y: auto;
}

::-webkit-scrollbar {
  width: 6px;
  height: 6px;
  -webkit-transition: background 0.3s;
  transition: background 0.3s;
}

::-webkit-scrollbar-corner {
  background: 0 0;
}

::-webkit-scrollbar-thumb {
  border-radius: 0.25rem;
  background-color: rgb(156, 163, 175);
}

::-webkit-scrollbar-track {
  background-color: rgb(229, 231, 235);
}
</style>
