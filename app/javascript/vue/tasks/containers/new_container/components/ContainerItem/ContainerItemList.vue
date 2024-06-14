<template>
  <table class="table-striped full_width">
    <thead>
      <tr>
        <th>Container Item</th>
        <th />
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in store.containerItems"
        :key="item.uuid"
      >
        <td :title="item.label">
          <div class="container-item-column ellipsis">{{ item.label }}</div>
        </td>
        <td>
          <div class="horizontal-right-content">
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
</template>

<script setup>
import { useContainerStore } from '../../store'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const store = useContainerStore()
</script>

<style scoped>
.container-item-column {
  max-width: 200px;
}
</style>
