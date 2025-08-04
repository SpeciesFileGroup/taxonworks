<template>
  <table
    :class="['group table-striped', { 'group-hidden': allHidden }]"
    :style="`border-color: ${group.color}`"
  >
    <thead>
      <tr
        ref="header"
        :class="[
          'group-header',
          group.list.some((o) => isObjectHover(o)) && 'row-hover'
        ]"
      >
        <th class="w-6">
          <input
            type="checkbox"
            v-model="selectAll"
          />
        </th>

        <th class="label-column">
          <div class="flex-separate gap-medium middle">
            <div class="flex-row gap-medium middle ellipsis">
              <VIcon
                class="cursor-pointer"
                :name="group.isListVisible ? 'arrowDown' : 'arrowRight'"
                x-small
                @click="group.isListVisible = !group.isListVisible"
              />
              <span
                class="ellipsis"
                v-html="group.determination.label"
              />
            </div>
            <span>({{ group.list.length }})</span>
          </div>
        </th>
        <th class="w-8">
          <div class="horizontal-right-content gap-small full_width">
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
          </div>
        </th>
      </tr>
    </thead>
    <tbody v-if="group.isListVisible">
      <tr
        v-for="item in group.list"
        :key="item.id"
        ref="rows"
        :class="['no_bullets group-list', isObjectHover(item) && 'row-hover']"
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
          <div class="horizontal-right-content">
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
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { computed, watch, useTemplateRef, nextTick } from 'vue'
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

const rowRefs = useTemplateRef('rows')
const headerRef = useTemplateRef('header')

function isObjectHover(o) {
  return store.hoverIds.includes(o.id)
}

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

watch(
  () => store.clickedLayer,
  (feature) => {
    const [id] = feature.properties.objectIds
    const index = props.group.list.findIndex((o) => o.id === id)

    if (index > -1) {
      if (!props.group.isListVisible) {
        store.updateGroupByUUID(props.group.uuid, {
          isListVisible: true
        })
      }

      nextTick(() => {
        const element = rowRefs.value?.[index] || headerRef.value

        element.scrollIntoView()
      })
    }
  }
)
</script>

<style scoped>
.group-hidden {
  opacity: 0.4;
}
.group {
  border-left: 4px solid;
  width: 100%;
  max-width: 400px;
  min-width: 100%;
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

    svg {
      min-width: max-content;
    }
  }

  .group-header {
    th,
    th:hover {
      background-color: var(--bg-color);
    }
  }

  td,
  th {
    transition: all 0.25s ease;
  }

  .row-hover {
    td,
    th {
      background-color: var(--table-row-bg-hover);
    }
  }
}
</style>
