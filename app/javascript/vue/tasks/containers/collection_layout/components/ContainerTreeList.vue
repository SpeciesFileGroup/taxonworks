<template>
  <div class="container-list panel content">
    <h3>Containers in building</h3>
    <div
      v-if="!buildingId"
      class="subtle"
    >
      <i>Select or create a building to see containers.</i>
    </div>
    <ul
      v-else-if="items.length"
      class="container-list-items"
    >
      <li
        v-for="item in items"
        :key="item.id"
        :style="{ marginLeft: item.depth * 1.5 + 'em' }"
        class="container-list-item"
        @click="$emit('navigate', item.path)"
      >
        <span class="container-type-badge">{{ item.typeName }}</span>
        {{ item.name }}
      </li>
    </ul>
    <div
      v-else
      class="subtle"
    >
      <i>No containers yet. Use &lsquo;Add&rsquo; above.</i>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'
import { displayType } from '../utils/containerType'

const props = defineProps({
  buildingId: {
    type: Number,
    default: null
  }
})

defineEmits(['navigate'])

const items = ref([])

function flattenTree(node, depth, ancestors = []) {
  const typeName = displayType(node.type)
  const self = { id: node.id, name: node.name || typeName, type: node.type }
  const path = [...ancestors, self]
  const rows = [{ id: node.id, name: node.name, typeName, depth, path }]
  for (const child of node.children || []) {
    rows.push(...flattenTree(child, depth + 1, path))
  }
  return rows
}

async function refresh() {
  if (!props.buildingId) {
    items.value = []
    return
  }
  const { body } = await AjaxCall(
    'get',
    '/tasks/containers/collection_visualization/collection_tree.json',
    {
      params: { building_id: props.buildingId }
    }
  )
  if (body?.id) {
    items.value = flattenTree(body, 0)
  } else {
    items.value = []
  }
}

watch(() => props.buildingId, refresh, { immediate: true })

defineExpose({ refresh })
</script>

<style scoped>
.container-list {
  flex: 0 0 340px;
  min-width: 240px;
  overflow-y: auto;
  max-height: 60vh;
}

.container-list-items {
  list-style: none;
  padding: 0;
  margin: 0;
  font-size: 0.9em;
}

.container-list-items li {
  padding: 2px 0;
}

.container-list-item {
  cursor: pointer;
  border-radius: 3px;
  padding: 3px 4px;
}

.container-list-item:hover {
  background: var(--bg-color);
}

.container-type-badge {
  background: #e8e8e8;
  border-radius: 3px;
  padding: 0 4px;
  font-size: 0.8em;
  margin-right: 4px;
  color: #555;
}
</style>
