<template>
  <table
    :class="['group', { 'group-hidden': allHidden }]"
    :style="`border-color: ${group.color}`"
  >
    <thead>
      <tr class="group-header">
        <th class="w-6">
          <input
            type="checkbox"
            v-model="selectAll"
          />
        </th>

        <th class="label-column ellipsis">
          <span
            class="ellipsis"
            v-html="group.determination.label"
          />
        </th>
        <th class="w-8">
          <VIcon
            class="cursor-pointer"
            :name="allHidden ? 'hide' : 'show'"
            small
            @click="toggleGroup"
          />
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in group.list"
        :key="item.id"
        class="no_bullets group-list"
      >
        <td>
          <input
            type="checkbox"
            :value="item.objectId"
            v-model="store.selectedIds"
          />
        </td>
        <td class="label-column ellipsis"><span v-html="item.label" /></td>
        <td>
          <VIcon
            class="cursor-pointer"
            :name="store.hiddenIds.includes(item.objectId) ? 'hide' : 'show'"
            small
            @click="
              () =>
                store.setObjectVisibilityById(
                  item.objectId,
                  !store.hiddenIds.includes(item.objectId)
                )
            "
          />
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { computed } from 'vue'
import useStore from '../../store/store.js'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  group: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['toggle'])
const store = useStore()

const selectAll = computed({
  get: () =>
    props.group.list.every((item) => store.selectedIds.includes(item.objectId)),
  set: (value) => {
    const groupIds = props.group.list.map((item) => item.objectId)

    if (value) {
      props.group.list.forEach((item) => {
        if (!store.selectedIds.includes(item.objectId)) {
          store.selectedIds.push(item.objectId)
        }
      })
    } else {
      store.selectedIds = store.selectedIds.filter(
        (id) => !groupIds.includes(id)
      )
    }
  }
})

const allHidden = computed(() =>
  props.group.list.every((item) => store.hiddenIds.includes(item.objectId))
)

function toggleGroup() {
  const value = !allHidden.value

  props.group.list.forEach((item) => {
    store.setObjectVisibilityById(item.objectId, value)
  })
}
</script>

<style scoped>
.group-hidden {
  opacity: 0.4;
}
.group {
  border-left: 4px solid;
  width: 400px;
  max-width: 400px;
  table-layout: fixed;

  .checkbox-column {
    width: 20px;
  }

  .label-column {
    width: auto;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    padding-left: 0;
    padding-right: 0;
  }

  .group-header {
    th,
    th:hover {
      background-color: var(--bg-color);
    }
  }

  .group-label {
    width: 340px;
    max-width: 340px;
    font-size: 12px;
  }

  .group-list {
    li {
      width: 360px;
      max-width: 360px;
      padding: 0.5rem;
      box-sizing: border-box;
      border-bottom: 1px solid var(--border-color);
      font-size: 12px;
    }
  }
}
</style>
