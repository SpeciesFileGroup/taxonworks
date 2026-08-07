<template>
  <VBtn
    color="primary"
    medium
    :container-style="{
      width: '500px'
    }"
    @click="
      () => {
        getImages()
        isModalVisible = true
      }
    "
  >
    Recent
  </VBtn>
  <VModal
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Recent images</h3>
    </template>
    <template #body>
      <VSpinner v-if="isLoading" />
      <table class="table-striped full_width">
        <thead>
          <tr>
            <th>Image</th>
            <th />
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="item in images"
            :key="item.id"
          >
            <td v-html="item.object_tag"></td>
            <td>
              <VBtn
                color="primary"
                medium
                @click="() => openImage(item.id)"
              >
                Select
              </VBtn>
            </td>
          </tr>
        </tbody>
      </table>
    </template>
  </VModal>
</template>

<script setup>
import { ref } from 'vue'
import { Image } from '@/routes/endpoints'
import { COLLECTION_OBJECT } from '@/constants'
import { RouteNames } from '@/routes/routes'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const isModalVisible = ref(false)
const isLoading = ref(false)
const images = ref([])

function getImages() {
  isLoading.value = true

  Image.filter({
    freeform_svg: true,
    per: 4,
    recent: true,
    depiction_object_type: COLLECTION_OBJECT
  })
    .then(({ body }) => {
      images.value = body
    })
    .finally(() => {
      isLoading.value = false
    })
}

function openImage(id) {
  window.open(`${RouteNames.FreeFormTask}?image_id=${id}`, '_self')
}
</script>
