<template>
  <VBtn
    color="primary"
    medium
    @click="isModalVisible = true"
  >
    Recent
  </VBtn>
  <VModal
    v-if="isModalVisible"
    :container-style="{ width: '700px', maxWidth: '90vw' }"
    @close="isModalVisible = false"
  >
    <template #header>
      <h3>Recent</h3>
    </template>
    <template #body>
      <VSpinner v-if="isLoading" />
      <p v-else-if="!list.length">No recent compositions.</p>
      <table
        v-else
        class="full_width table-striped"
      >
        <thead>
          <tr>
            <th>Name</th>
            <th>Description</th>
            <th>Updated</th>
            <th class="w-2" />
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="item in list"
            :key="item.id"
          >
            <td>{{ item.name }}</td>
            <td>{{ item.description }}</td>
            <td>{{ new Date(item.updated_at).toLocaleString() }}</td>
            <td>
              <VBtn
                color="primary"
                circle
                title="Open"
                @click="select(item)"
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
import { ref, watch } from 'vue'
import { Composition } from '@/routes/endpoints'
import { LAYOUT_TASK } from '@/constants'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const emit = defineEmits(['select'])

const list = ref([])
const isLoading = ref(false)
const isModalVisible = ref(false)

// Layout::Task Compositions only
watch(isModalVisible, (visible) => {
  if (!visible) return

  isLoading.value = true

  Composition.selectOptions({ type: LAYOUT_TASK })
    .then(({ body }) => {
      list.value = body.recent
    })
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
    })
})

function select(item) {
  isModalVisible.value = false
  emit('select', item)
}
</script>
