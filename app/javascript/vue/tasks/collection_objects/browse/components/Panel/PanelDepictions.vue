<template>
  <PanelContainer title="Depictions">
    <div class="flex-wrap-row">
      <ImageViewer
        v-for="depiction in depictions"
        :key="depiction.id"
        :depiction="depiction"
      />
    </div>
  </PanelContainer>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters.js'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer'
import PanelContainer from './PanelContainer.vue'

const store = useStore()
const depictions = computed(() => store.getters[GetterNames.GetDepictions])
</script>
