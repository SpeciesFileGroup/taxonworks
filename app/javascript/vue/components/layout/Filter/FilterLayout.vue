<template>
  <NavBar>
    <div class="middle grid-filter__nav">
      <div class="flex-separate middle">
        <div class="horizontal-left-content gap-small">
          <VBtn
            color="primary"
            medium
            @click="handleClickFilterButton"
          >
            Filter
          </VBtn>
          <label>
            <input
              type="checkbox"
              v-model="appendValue"
            />
            Append
          </label>
        </div>
        <ModalNestedParameters :parameters="parameters" />
        <div class="horizontal-left-content">
          <RadialFilter
            v-if="objectType"
            :parameters="parameters"
            :object-type="objectType"
            :disabled="!list.length"
          />
          <RadialLinker
            v-if="objectType"
            all
            :parameters="parameters"
            :object-type="objectType"
            :disabled="!list.length"
          />
        </div>
      </div>
      <span>|</span>
      <slot name="nav-left" />
      <div class="flex-separate">
        <pagination-component
          v-if="pagination"
          :pagination="pagination"
          @next-page="emit('nextpage', $event)"
        />
        <pagination-count
          v-if="pagination"
          :pagination="pagination"
          v-model="perValue"
        />
      </div>
      <div class="horizontal-right-content">
        <RadialFilter
          v-if="selectedIds"
          :ids="selectedIds"
          :disabled="!selectedIds.length"
          :object-type="objectType"
        />
        <RadialLinker
          v-if="selectedIds"
          :ids="selectedIds"
          :disabled="!selectedIds.length"
          :object-type="objectType"
        />
        <RadialMassAnnotator
          v-if="selectedIds"
          :object-type="objectType"
          :ids="selectedIds"
        />
        <slot name="nav-right" />
        <span class="separate-left separate-right">|</span>
        <FilterSettings
          v-model:filter="preferences.activeFilter"
          v-model:url="preferences.activeJSONRequest"
          v-model:list="preferences.showList"
        >
          <template #preferences-last>
            <slot name="preferences-last" />
          </template>
        </FilterSettings>
        <VBtn
          color="primary"
          class="circle-button"
          @click="emit('reset')"
        >
          <VIcon
            name="reset"
            x-small
          />
        </VBtn>
      </div>
    </div>
  </NavBar>
  <div
    class="grid-filter"
    :class="{ 'grid-filter--without-facets': !filter }"
  >
    <div
      v-show="filter"
      class="grid-filter__facets margin-medium-bottom"
    >
      <slot name="facets">
        <component
          v-for="(facet, index) in facets"
          :key="index"
          :is="facet.component"
          v-bind="facet.props"
          v-model="params"
        />
      </slot>
    </div>

    <slot
      v-if="table"
      name="table"
    />
  </div>
</template>

<script setup>
import PaginationComponent from 'components/pagination'
import PaginationCount from 'components/pagination/PaginationCount'
import NavBar from 'components/layout/NavBar.vue'
import useHotkey from 'vue3-hotkey'
import platformKey from 'helpers/getPlatformKey'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import RadialFilter from 'components/radials/filter/radial.vue'
import ModalNestedParameters from 'components/Filter/ModalNestedParameters.vue'
import RadialLinker from 'components/radials/linker/radial.vue'
import RadialMassAnnotator from 'components/radials/mass/radial.vue'
import FilterSettings from './FilterSettings.vue'

import { ref, computed, onBeforeUnmount } from 'vue'

const props = defineProps({
  filter: {
    type: Boolean,
    default: false
  },

  table: {
    type: Boolean,
    default: false
  },

  pagination: {
    type: Object,
    default: undefined
  },

  per: {
    type: Number,
    default: 500
  },

  objectType: {
    type: String,
    default: undefined
  },

  selectedIds: {
    type: Array,
    default: undefined
  },

  parameters: {
    type: Object,
    default: () => ({})
  },

  preferences: {
    type: Object,
    default: () => ({})
  },

  facets: {
    type: Array,
    default: () => []
  },

  modelValue: {
    type: Object,
    default: () => ({})
  },

  list: {
    type: Array,
    required: true
  },

  append: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits([
  'reset',
  'filter',
  'nextpage',
  'update:per',
  'update:modelValue',
  'update:append',
  'update:preferences'
])

const appendValue = computed({
  get: () => props.append,
  set: (value) => emit('update:append', value)
})

const perValue = computed({
  get: () => props.per,
  set: (value) => emit('update:per', value)
})

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const preferences = computed({
  get: () => props.preferences,
  set: (value) => emit('update:preferences', value)
})

const hotkeys = ref([
  {
    keys: [platformKey(), 'f'],
    preventDefault: true,
    handler() {
      emit('filter')
    }
  },
  {
    keys: [platformKey(), 'r'],
    preventDefault: true,
    handler() {
      emit('reset')
    }
  }
])

function handleClickFilterButton() {
  emit('filter')
  window.scrollTo(0, 0)
}

TW.workbench.keyboard.createLegend(
  `${platformKey()}+f`,
  'Search',
  'Filter sources'
)
TW.workbench.keyboard.createLegend(
  `${platformKey()}+r`,
  'Reset task',
  'Filter sources'
)

const stop = useHotkey(hotkeys.value)

onBeforeUnmount(() => {
  stop()
})
</script>

<style scoped>
.grid-filter {
  display: grid;
  gap: 1em;
  grid-template-columns: 400px 1fr;
}

.grid-filter--without-facets {
  grid-template-columns: 1fr;
}

.grid-filter__facets {
  width: 400px;
  max-width: 400px;
  flex-direction: column;
  display: flex;
  gap: 1em;
}

.grid-filter__nav {
  display: grid;
  grid-template-columns: 380px 2px 1fr 1fr;
  gap: 1em;
}

:deep(.btn-delete) {
  background-color: #5d9ece;
}
</style>
