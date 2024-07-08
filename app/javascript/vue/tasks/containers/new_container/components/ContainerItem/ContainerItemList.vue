<template>
  <table class="table-striped full_width">
    <thead>
      <tr>
        <th class="w-2">
          <input
            type="checkbox"
            v-model="selectAll"
          />
        </th>
        <th>{{ title }}</th>
        <th>
          <div class="horizontal-right-content">
            <FillContainerModal
              v-if="fillButton"
              :disabled="!listSelected.length"
              :list="listSelected"
            />
          </div>
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in list"
        :key="item.uuid"
        @mouseover="() => (store.hoverRow = item)"
        @mouseout="() => (store.hoverRow = null)"
      >
        <td>
          <input
            type="checkbox"
            :checked="!!store.getSelectedContainerItemByUUID(item.uuid)"
            @change="() => toggleItem(item)"
          />
        </td>
        <td :title="item.label">
          <div class="container-item-column ellipsis">{{ item.label }}</div>
        </td>
        <td>
          <div class="horizontal-right-content gap-small">
            <VBtn
              v-if="!store.isItemInside(item)"
              color="primary"
              @click="() => (store.placeItem = item)"
            >
              Place
            </VBtn>
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
import { computed } from 'vue'
import { useContainerStore } from '../../store'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import FillContainerModal from './ContainerItemFill.vue'

const props = defineProps({
  list: {
    type: Array,
    required: true
  },

  title: {
    type: String,
    required: true
  },

  fillButton: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['edit'])

const listSelected = computed(() =>
  props.list.filter((item) =>
    store.selectedItems.some((i) => i.metadata?.uuid === item.uuid)
  )
)

const selectAll = computed({
  get() {
    return props.list.every(({ uuid }) =>
      store.selectedItems.some((i) => uuid === i.uuid)
    )
  },
  set(value) {
    if (value) {
      props.list.forEach(store.addSelectedItem)
    } else {
      props.list.forEach(store.removeSelectedItem)
    }
  }
})

const store = useContainerStore()

function removeItem(item) {
  if (
    !item.id ||
    window.confirm('Are you sure you want to delete this item?')
  ) {
    store.removeContainerItem(item)
  }
}

function toggleItem(item) {
  const alreadySelected = store.getSelectedContainerItemByUUID(item.uuid)

  if (alreadySelected) {
    store.removeSelectedItem(item)
  } else {
    store.addSelectedItem(item)
  }
}
</script>

<style scoped>
.container-item-column {
  max-width: 200px;
}
</style>
