<template>
  <PanelContainer title="Depictions">
    <VPagination
      class="margin-large-top"
      :pagination="pagination"
      @next-page="loadDepictions"
    />
    <div class="flex-wrap-row depictions-list">
      <ImageViewer
        v-for="depiction in list"
        :key="depiction.id"
        :depiction="depiction"
      />
    </div>
  </PanelContainer>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Depiction } from '@/routes/endpoints.js'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer'
import PanelContainer from './PanelContainer.vue'
import VPagination from '@/components/pagination.vue'
import getPagination from '@/helpers/getPagination.js'

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

const pagination = ref()
const list = ref([])

function loadDepictions(page = 1) {
  Depiction.where({
    depiction_object_id: props.objectId,
    depiction_object_type: props.objectType,
    page
  })
    .then((response) => {
      pagination.value = getPagination(response)
      list.value = response.body
    })
    .catch(() => {})
}

watch(
  () => props.objectId,
  (id) => {
    list.value = []

    if (id) {
      loadDepictions()
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
