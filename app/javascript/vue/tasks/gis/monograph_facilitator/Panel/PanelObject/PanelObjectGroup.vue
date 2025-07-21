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
            v-if="
              group.list.every(
                (item) => store.getGeoreferencesByObjectId(item.id).length
              )
            "
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
            :value="item.id"
            v-model="store.selectedIds"
          />
        </td>
        <td class="label-column ellipsis">
          <a
            :href="makeBrowseUrl(item)"
            v-html="item.label"
          />
        </td>
        <td>
          <VIcon
            v-if="store.getGeoreferencesByObjectId(item.id).length"
            class="cursor-pointer"
            :name="store.hiddenIds.includes(item.id) ? 'hide' : 'show'"
            small
            @click="
              () =>
                store.setObjectVisibilityById(
                  item.id,
                  !store.hiddenIds.includes(item.id)
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
import { RouteNames } from '@/routes/routes.js'
import { COLLECTION_OBJECT, FIELD_OCCURRENCE } from '@/constants'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams.js'
import useStore from '../../store/store.js'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  group: {
    type: Object,
    required: true
  }
})

const BROWSE_LINKS = {
  [COLLECTION_OBJECT]: RouteNames.BrowseCollectionObject,
  [FIELD_OCCURRENCE]: RouteNames.BrowseFieldOccurrence
}

const emit = defineEmits(['toggle'])
const store = useStore()

const selectAll = computed({
  get: () =>
    props.group.list.every((item) => store.selectedIds.includes(item.id)),
  set: (value) => {
    const groupIds = props.group.list.map((item) => item.id)

    if (value) {
      props.group.list.forEach((item) => {
        if (!store.selectedIds.includes(item.id)) {
          store.selectedIds.push(item.id)
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
  props.group.list.every(
    (item) =>
      store.hiddenIds.includes(item.id) ||
      !store.getGeoreferencesByObjectId(item.id).length
  )
)

function toggleGroup() {
  const value = !allHidden.value

  props.group.list.forEach((item) => {
    store.setObjectVisibilityById(item.id, value)
  })
}

function makeBrowseUrl(obj) {
  const idParam = ID_PARAM_FOR[obj.type]

  return `${BROWSE_LINKS[obj.type]}?${idParam}=${obj.id}`
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
