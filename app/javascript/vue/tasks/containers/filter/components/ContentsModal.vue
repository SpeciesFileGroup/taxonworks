<template>
  <VModal
    :container-style="{ width: '700px' }"
    @close="() => emit('close')"
  >
    <template #header>
      <h3>Items {{ container?.object_label }}</h3>
    </template>
    <template #body>
      <VSpinner v-if="isLoading" />
      <p v-else-if="!containerItems.length">No items in this container.</p>
      <table
        v-else
        class="full_width table-striped"
      >
        <thead>
          <tr>
            <th>Object</th>
            <th>Type</th>
            <th>Position</th>
            <th>Disposition</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="item in containerItems"
            :key="item.id"
          >
            <td v-html="item.contained_object.object_tag" />
            <td>{{ item.contained_object.base_class }}</td>
            <td>{{ formatPosition(item) }}</td>
            <td>{{ item.disposition }}</td>
          </tr>
        </tbody>
      </table>
    </template>
  </VModal>
</template>

<script setup>
import { computed, ref } from 'vue'
import { Container } from '@/routes/endpoints'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const props = defineProps({
  containerId: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['close'])

const container = ref(null)
const isLoading = ref(true)

const containerItems = computed(() => container.value?.container_items || [])

function formatPosition({ disposition_x, disposition_y, disposition_z }) {
  return [disposition_x, disposition_y, disposition_z]
    .filter((coordinate) => coordinate !== null && coordinate !== undefined)
    .join(', ')
}

Container.find(props.containerId, { extend: ['container_items'] })
  .then(({ body }) => {
    container.value = body
  })
  .finally(() => {
    isLoading.value = false
  })
</script>
