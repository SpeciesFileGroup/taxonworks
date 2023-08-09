<template>
  <VIcon
    v-if="cachedMap.synced"
    color="create"
    class="absolute cached-map-icon cursor-pointer"
    name="check"
    :title="`Time between data and sync: ${cachedMap.time_between_data_and_sync}`"
    @click="isModalVisible = true"
  />
  <VIcon
    v-else
    color="warning"
    class="absolute cached-map-icon cursor-pointer"
    name="attention"
    :title="`Time between data and sync: ${cachedMap.time_between_data_and_sync}`"
    @click="isModalVisible = true"
  />
  <VModal
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Source scope</h3>
    </template>
    <template #body>
      <ul>
        <li
          v-for="(value, key) in cachedMap.source_scope"
          :key="key"
        >
          {{ key }}: {{ value }}
        </li>
      </ul>
    </template>
  </VModal>
</template>
<script setup>
import { ref } from 'vue'
import VModal from '@/components/ui/Modal.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

defineProps({
  cachedMap: {
    type: Object,
    required: true
  }
})

const isModalVisible = ref(false)
</script>

<style>
.cached-map-icon {
  right: 20px;
  top: 20px;
  z-index: 1098;
}
</style>
