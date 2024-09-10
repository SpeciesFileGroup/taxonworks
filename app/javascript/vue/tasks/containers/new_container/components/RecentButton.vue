<template>
  <VBtn
    color="primary"
    medium
    @click="() => (isModalVisible = true)"
  >
    Recent
  </VBtn>
  <VModal
    v-if="isModalVisible"
    :container-style="{
      width: '500px'
    }"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Recent</h3>
    </template>
    <template #body>
      <VSpinner v-if="isLoading" />
      <table class="full_width table-striped">
        <thead>
          <tr>
            <th>Container</th>
            <th />
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="item in list"
            :key="item.id"
            class="cursor-pointer"
            @click="
              () => {
                store.loadContainer(item.id)
                isModalVisible = false
              }
            "
          >
            <td v-html="item.object_tag" />
            <td>
              <div class="horizontal-right-content">
                <VBtn
                  color="primary"
                  circle
                >
                  <VIcon
                    name="pencil"
                    x-small
                  />
                </VBtn>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </template>
  </VModal>
</template>

<script setup>
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { Container } from '@/routes/endpoints'
import { ref, watch } from 'vue'
import { useContainerStore } from '../store'

const store = useContainerStore()
const list = ref([])
const isLoading = ref(false)
const isModalVisible = ref(false)

watch(isModalVisible, (newVal) => {
  if (newVal) {
    isLoading.value = true

    Container.where({
      per: 10,
      recent: true
    })
      .then(({ body }) => {
        list.value = body
      })
      .catch(() => {})
      .finally(() => {
        isLoading.value = false
      })
  }
})
</script>
