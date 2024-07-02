<template>
  <VBtn
    v-if="cachedMap.synced"
    circle
    large
    class="absolute cursor-pointer cached-map-icon"
  >
    <VIcon
      color="create"
      name="check"
      :title="`Time between data and sync: ${cachedMap.time_between_data_and_sync}`"
      @click="isModalVisible = true"
    />
  </VBtn>
  <VBtn
    v-else
    circle
    large
    class="absolute cursor-pointer cached-map-icon"
  >
    <VIcon
      color="warning"
      name="attention"
      small
      :title="`Time between data and sync: ${cachedMap.time_between_data_and_sync}`"
      @click="isModalVisible = true"
    />
  </VBtn>

  <VModal
    v-if="isModalVisible"
    :container-style="{ width: '1000px' }"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Cached map</h3>
    </template>
    <template #body>
      <div>
        <table class="table-striped full_width">
          <thead>
            <tr>
              <th>Data</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Is synced</td>
              <td>
                <div
                  class="horizontal-left-content middle"
                  v-if="cachedMap.synced"
                >
                  <span class="margin-xsmall-left text-create-color">
                    Map is synchronized with the latest changes *
                  </span>
                </div>
                <div
                  class="text-warning-color horizontal-left-content middle"
                  v-else
                >
                  <VIcon
                    name="attention"
                    color="warning"
                    small
                  />
                  <span class="margin-xsmall-left">
                    Map is not synchronized with the latest changes *
                  </span>
                </div>
              </td>
            </tr>
            <tr>
              <td>Last update</td>
              <td>
                {{ new Date(cachedMap.updated_at) }}
              </td>
            </tr>
          </tbody>
          <thead>
            <tr>
              <th>Source</th>
              <th>Total</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(value, key) in cachedMap.source_scope"
              :key="key"
            >
              <td class="capitalize">
                {{ key.replaceAll('_', ' ') }}
              </td>
              <td>
                {{ value }}
              </td>
            </tr>
          </tbody>
        </table>
        <p class="italic font_small padding-small">
          * Aggregate maps are generated from georeference and asserted
          distribution data. Map computation takes time, and as such they are
          re-calculated periodically rather than when individual georeferences
          and asserted distributions are created, destroyed, or updated. When a
          warning notice is present then the map is not syncronized with the
          latest changes to the underlying data.
        </p>
      </div>
    </template>
  </VModal>
</template>
<script setup>
import { ref } from 'vue'
import VModal from '@/components/ui/Modal.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

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
