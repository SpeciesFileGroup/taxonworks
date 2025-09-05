<template>
  <VBtn
    color="primary"
    type="button"
    medium
    @click="() => (isModalVisible = true)"
  >
    Recent
  </VBtn>
  <VModal
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Recent</h3>
    </template>
    <template #body>
      <VSpinner v-if="isSearching" />
      <table class="table-striped">
        <thead>
          <tr>
            <th>Name</th>
            <th>Description</th>
            <th>Type</th>
            <th class="w-2" />
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="item in descriptors"
            :key="item.id"
          >
            <td>{{ item.name }}</td>
            <td>{{ item.description }}</td>
            <td>{{ item.type }}</td>
            <td>
              <VBtn
                color="primary"
                circle
                @click="
                  () => {
                    emit('select', item)
                    isModalVisible = false
                  }
                "
              >
                <VIcon
                  name="pencil"
                  x-small
                />
              </VBtn>
            </td>
          </tr>
        </tbody>
      </table>
    </template>
  </VModal>
</template>

<script setup>
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { Descriptor } from '@/routes/endpoints'
import { ref, watch } from 'vue'

const descriptors = ref([])
const isSearching = ref(false)
const isModalVisible = ref(false)

const emit = defineEmits(['select'])

function loadDescriptors() {
  isSearching.value = true
  Descriptor.where({ per: 10, recent: true })
    .then(({ body }) => {
      descriptors.value = body
    })
    .finally(() => {
      isSearching.value = false
    })
}

watch(isModalVisible, (isVisible) => {
  if (isVisible) {
    loadDescriptors()
  }
})
</script>

<style scoped>
:deep(.modal-container) {
  width: 500px;
}
textarea {
  height: 100px;
}
:deep(.modal-container) {
  width: 800px !important;
}
</style>
