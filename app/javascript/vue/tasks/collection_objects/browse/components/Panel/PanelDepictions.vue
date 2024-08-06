<template>
  <PanelContainer title="Depictions">
    <VPagination
      class="margin-large-top"
      :pagination="depictions.pagination"
      @next-page="loadDepictions"
    />
    <div class="flex-wrap-row depictions-list">
      <ImageViewer
        v-for="depiction in depictions.list"
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
import { ActionNames } from '../../store/actions/actions.js'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer'
import PanelContainer from './PanelContainer.vue'
import VPagination from '@/components/pagination.vue'

const store = useStore()
const depictions = computed(() => store.getters[GetterNames.GetDepictions])
const coId = computed(() => store.getters[GetterNames.GetCollectionObject]?.id)

function loadDepictions({ page }) {
  store.dispatch(ActionNames.LoadDepictions, { page, id: coId.value })
}
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
