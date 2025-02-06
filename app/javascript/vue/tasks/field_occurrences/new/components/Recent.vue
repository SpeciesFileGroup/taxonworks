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
    :container-style="{ width: '90vw' }"
    @close="isModalVisible = false"
  >
    <template #header>
      <h3>Recent field occurrences</h3>
    </template>
    <template #body>
      <VSpinner v-if="isLoading" />
      <table class="full_width table-striped">
        <thead>
          <tr>
            <th>Total</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="item in list"
            :key="item.id"
            @click="selectFO(item)"
          >
            <td
              v-html="item.object_tag"
              class="cursor-pointer"
            />
          </tr>
        </tbody>
      </table>
    </template>
  </VModal>
</template>

<script setup>
import VModal from '@/components/ui/Modal'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { FieldOccurrence } from '@/routes/endpoints'
import { ref, watch } from 'vue'

const emit = defineEmits(['selected'])

const isModalVisible = ref(false)
const isLoading = ref(false)
const list = ref([])

watch(isModalVisible, (newVal) => {
  if (newVal) {
    isLoading.value = true
    FieldOccurrence.where({ per: 10, recent: true }).then(({ body }) => {
      list.value = body
      isLoading.value = false
    })
  }
})

function selectFO(item) {
  isModalVisible.value = false
  emit('selected', item)
}
</script>
