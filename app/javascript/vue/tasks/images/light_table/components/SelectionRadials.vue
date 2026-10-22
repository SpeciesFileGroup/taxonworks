<template>
  <div>
    <VBtn
      circle
      variant="ghost"
      color="default"
      title="Batch actions"
      :disabled="!groups.length"
      @click.stop="openMenu"
    >
      <VIcon
        name="hamburger"
        x-small
      />
    </VBtn>
    <ContextMenu
      ref="contextMenuRef"
      class="light-table-selection-radials__menu"
    >
      <LightTableSubmenu
        v-for="group in groups"
        :key="group.objectType"
        :label="`${group.label} (${group.ids.length})`"
      >
        <LightTableMenuItem
          v-for="radial in group.radials"
          :key="radial.label"
          :label="radial.label"
          @click="openRadial(radial, group)"
        />
      </LightTableSubmenu>
    </ContextMenu>
    <component
      :is="active.component"
      v-if="active"
      ref="radialRef"
      :key="active.key"
      :show-bottom="false"
      :ids="active.ids"
      :count="active.ids.length"
      :object-type="active.objectType"
      :model="active.objectType"
    />
  </div>
</template>

<script setup>
import { computed, nextTick, ref, shallowRef } from 'vue'
import {
  COLLECTION_OBJECT,
  DEPICTION,
  DWC_OCCURRENCE,
  IMAGE
} from '@/constants'
import { LightTableMenuItem, LightTableSubmenu } from '@/components/LightTable'
import * as FILTER_LINKS from '@/components/radials/filter/links'
import * as LINKER_LIST from '@/components/radials/linker/links/index.js'
import { ANNOTATORS } from '@/components/radials/mass/constants/annotators.js'
import ContextMenu from '@/components/ui/Context/ContextMenu.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import RadialFilter from '@/components/radials/filter/radial.vue'
import RadialLinker from '@/components/radials/linker/radial.vue'
import RadialMassAnnotator from '@/components/radials/mass/radial.vue'
import RadialNavigation from '@/components/radials/MassNavigation/radial.vue'
import RadialCollectionObject from '@/components/radials/co/radial.vue'

const RADIALS = [
  {
    label: 'Radial filter',
    component: RadialFilter,
    supports: (type) => !!FILTER_LINKS[type]
  },
  {
    label: 'Radial linker',
    component: RadialLinker,
    supports: (type) => !!LINKER_LIST[type]
  },
  {
    label: 'Radial batch annotator',
    component: RadialMassAnnotator,
    supports: (type) =>
      type !== DWC_OCCURRENCE && !!(ANNOTATORS[type] || FILTER_LINKS[type])
  },
  {
    label: 'Radial navigator',
    component: RadialNavigation,
    supports: () => true
  },
  {
    label: 'Radial collection object',
    component: RadialCollectionObject,
    supports: (type) => type === COLLECTION_OBJECT
  }
]

const props = defineProps({
  items: {
    type: Array,
    default: () => []
  }
})

const contextMenuRef = ref(null)
const radialRef = ref(null)
const active = shallowRef(null)

function humanize(className) {
  return className
    .replace(/([a-z])([A-Z])/g, '$1 $2')
    .replace(/ (.)/g, (_, c) => ` ${c.toLowerCase()}`)
}

const groups = computed(() => {
  const idsByType = new Map()

  function add(objectType, id) {
    if (!objectType || !id) return
    if (!idsByType.has(objectType)) idsByType.set(objectType, new Set())
    idsByType.get(objectType).add(id)
  }

  props.items.forEach(({ meta }) => {
    const { object } = meta

    if (meta.objectType === DEPICTION) {
      add(IMAGE, object.image_id)
      add(DEPICTION, object.id)
      add(object.depiction_object_type, object.depiction_object_id)
    } else {
      add(IMAGE, object.id)
    }
  })

  return [...idsByType].map(([objectType, ids]) => ({
    objectType,
    label: humanize(objectType),
    ids: [...ids],
    radials: RADIALS.filter((radial) => radial.supports(objectType))
  }))
})

function openMenu(event) {
  const { left, bottom } = event.currentTarget.getBoundingClientRect()

  contextMenuRef.value.openContextMenu({ x: left, y: bottom })
}

async function openRadial(radial, group) {
  active.value = {
    key: `${group.objectType}-${radial.label}`,
    component: radial.component,
    objectType: group.objectType,
    ids: group.ids
  }

  await nextTick()
  radialRef.value?.openRadialMenu()
}
</script>

<style scoped>
.light-table-selection-radials__menu {
  z-index: 1000;
  width: auto;
  min-width: 220px;
  overflow: visible;
  padding: var(--spacing-xxs) 0;
  border-radius: var(--border-radius-small);
}
</style>
