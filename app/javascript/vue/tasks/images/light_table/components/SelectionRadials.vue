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
    <LightTableMenu
      ref="menuRef"
      class="light-table-selection-radials__menu"
    >
      <LightTableSubmenu
        v-for="group in groups"
        :key="group.objectType"
        :label="`${group.label} (${group.ids.length})`"
      >
        <LightTableMenuItem
          v-for="item in group.radials"
          :key="item.label"
          :label="item.label"
          @click="openGroupRadial(item, group)"
        />
      </LightTableSubmenu>
    </LightTableMenu>
    <component
      :is="radial.component"
      v-if="radial"
      ref="radialRef"
      :key="radial.key"
      v-bind="radial.props"
      :show-bottom="false"
    />
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import {
  COLLECTION_OBJECT,
  DEPICTION,
  DWC_OCCURRENCE,
  IMAGE
} from '@/constants'
import {
  LightTableMenu,
  LightTableMenuItem,
  LightTableSubmenu
} from '@/components/LightTable'
import { capitalize, decamelize } from '@/helpers'
import { getImage } from '../adapters/source'
import { useRadialOpener } from '../composables/useRadialOpener'
import * as FILTER_LINKS from '@/components/radials/filter/links'
import * as LINKER_LIST from '@/components/radials/linker/links/index.js'
import { ANNOTATORS } from '@/components/radials/mass/constants/annotators.js'
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

const menuRef = ref(null)
const { radial, radialRef, openRadial } = useRadialOpener()

const groups = computed(() => {
  const idsByType = new Map()

  function add(objectType, id) {
    if (!objectType || !id) return
    if (!idsByType.has(objectType)) idsByType.set(objectType, new Set())
    idsByType.get(objectType).add(id)
  }

  props.items.forEach(({ meta }) => {
    add(IMAGE, getImage(meta).id)

    meta.depictions?.forEach((depiction) => {
      add(DEPICTION, depiction.id)
      add(depiction.depiction_object_type, depiction.depiction_object_id)
    })
  })

  return [...idsByType].map(([objectType, ids]) => ({
    objectType,
    label: capitalize(decamelize(objectType)),
    ids: [...ids],
    radials: RADIALS.filter((radial) => radial.supports(objectType))
  }))
})

function openMenu(event) {
  menuRef.value.openBelow(event.currentTarget)
}

function openGroupRadial(item, group) {
  openRadial({
    component: item.component,
    key: `${group.objectType}-${item.label}`,
    props: {
      ids: group.ids,
      count: group.ids.length,
      objectType: group.objectType,
      model: group.objectType
    }
  })
}
</script>

<style scoped>
.light-table-selection-radials__menu {
  padding: var(--spacing-xxs) 0;
}
</style>
