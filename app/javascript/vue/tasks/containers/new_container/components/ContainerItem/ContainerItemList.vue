<template>
  <table
    class="table-striped full_width"
    v-if="store.getItemsOutsideContainer.length"
  >
    <thead>
      <tr>
        <th>Container Items (Outside)</th>
        <th />
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in store.getItemsOutsideContainer"
        :key="item.uuid"
      >
        <td :title="item.label">
          <div class="container-item-column ellipsis">{{ item.label }}</div>
        </td>
        <td>
          <div class="horizontal-right-content gap-small">
            <VBtn
              color="primary"
              @click="() => (store.placeItem = item)"
            >
              Place
            </VBtn>
            <VBtn
              circle
              :color="item.id ? 'destroy' : 'primary'"
              @click="() => store.removeContainerItem(item)"
            >
              <VIcon
                x-small
                name="trash"
              />
            </VBtn>
          </div>
        </td>
      </tr>
    </tbody>
  </table>

  <table class="table-striped full_width">
    <thead>
      <tr>
        <th>Container Items (Inside)</th>
        <th />
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in store.getItemsInsideContainer"
        :key="item.uuid"
        @mouseover="() => (store.hoverRow = item)"
        @mouseout="() => (store.hoverRow = null)"
      >
        <td :title="item.label">
          <div class="container-item-column ellipsis">{{ item.label }}</div>
        </td>
        <td>
          <div class="horizontal-right-content gap-small">
            <VBtn
              circle
              color="primary"
              @click="() => emit('edit', item)"
            >
              <VIcon
                x-small
                name="pencil"
              />
            </VBtn>
            <VBtn
              circle
              :color="item.id ? 'destroy' : 'primary'"
              @click="() => removeItem(item)"
            >
              <VIcon
                x-small
                name="trash"
              />
            </VBtn>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { useContainerStore } from '../../store'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const emit = defineEmits(['edit'])

const store = useContainerStore()

function removeItem(item) {
  if (window.confirm('Are you sure you want to delete this item?')) {
    store.removeContainerItem(item)
  }
}
</script>

<style scoped>
.container-item-column {
  max-width: 200px;
}
</style>
