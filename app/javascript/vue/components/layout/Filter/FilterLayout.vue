<template>
  <FilterJsonRequestPanel
    v-show="preferences.activeJSONRequest"
    class="panel content separate-bottom"
    :url="urlRequest"
  />
  <NavBar navbar-class>
    <div class="middle grid-filter__nav">
      <div class="panel content">
        <div class="flex-separate middle gap-small">
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
            <ModalNestedParameters :parameters="parameters" />
            <slot name="nav-query-left" />
          </div>
          <div class="horizontal-left-content gap-small">
            <template v-if="objectType">
              <RadialFilter
                v-if="radialFilter"
                :parameters="parameters"
                :object-type="objectType"
                :disabled="!list.length"
              />
              <RadialLinker
                v-if="radialLinker"
                all
                :parameters="parameters"
                :object-type="objectType"
                :disabled="!list.length"
              />
              <RadialMassAnnotator
                v-if="radialMassAnnotator"
                :object-type="objectType"
                :parameters="parameters"
                :disabled="!list.length"
                nested-query
              />
            </template>
            <slot name="nav-query-right" />
            <span class="separate-left separate-right">|</span>
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
      </div>
      <div class="panel content">
        <div class="flex-separate">
          <slot name="nav-left" />
          <div>
            <PaginationComponent
              v-if="pagination"
              :pagination="pagination"
              @next-page="emit('nextpage', $event)"
            />
          </div>
          <PaginationCount
            v-if="pagination"
            :pagination="pagination"
            custom
            v-model="perValue"
          />
          <div class="horizontal-right-content gap-small">
            <slot name="nav-options-left" />
            <template v-if="selectedIds">
              <ButtonUnify
                v-if="buttonUnify"
                :ids="selectedIds"
                :model="objectType"
              />
              <RadialFilter
                v-if="radialFilter"
                :ids="selectedIds"
                :parameters="parameters"
                :disabled="!selectedIds.length"
                :object-type="objectType"
              />
              <RadialLinker
                v-if="radialLinker"
                :ids="selectedIds"
                :disabled="!selectedIds.length"
                :object-type="objectType"
              />
              <RadialMassAnnotator
                v-if="radialMassAnnotator"
                :object-type="objectType"
                :ids="selectedIds"
                :disabled="!selectedIds.length"
              />
              <RadialNavigation
                v-if="radialNavigator"
                :model="objectType"
                :ids="selectedIds"
                :disabled="!selectedIds.length"
              />
            </template>
            <slot name="nav-right" />
            <span class="separate-left separate-right">|</span>
            <FilterDownload
              :list="selectedItems"
              :csv-options="csvOptions"
              :extend-download="extendDownload"
              :only-extend-download="onlyExtendDownload"
            />
            <span class="separate-left separate-right">|</span>
            <FilterSettings
              v-model:filter="preferences.activeFilter"
              v-model:url="preferences.activeJSONRequest"
              v-model:list="preferences.showTable"
            >
              <template #preferences-last>
                <slot name="preferences-last" />
              </template>
            </FilterSettings>
          </div>
        </div>
      </div>
    </div>
  </NavBar>
  <div
    class="grid-filter"
    :class="{ 'grid-filter--without-facets': !preferences.activeFilter }"
  >
    <div
      v-show="preferences.activeFilter"
      class="grid-filter__facets margin-medium-bottom"
    >
      <slot name="facets" />
    </div>

    <div class="full_width overflow-x-auto">
      <slot name="above-table" />
      <slot
        v-if="preferences.showTable"
        name="table"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onBeforeUnmount, reactive } from 'vue'
import { useHotkey } from '@/composables'
import FilterDownload from './FilterDownload.vue'
import FilterJsonRequestPanel from './FilterJsonRequestPanel.vue'
import PaginationComponent from '@/components/pagination'
import PaginationCount from '@/components/pagination/PaginationCount'
import NavBar from '@/components/layout/NavBar.vue'
import platformKey from '@/helpers/getPlatformKey'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import RadialFilter from '@/components/radials/filter/radial.vue'
import ModalNestedParameters from '@/components/Filter/ModalNestedParameters.vue'
import RadialLinker from '@/components/radials/linker/radial.vue'
import RadialMassAnnotator from '@/components/radials/mass/radial.vue'
import FilterSettings from './FilterSettings.vue'
import RadialNavigation from '@/components/radials/MassNavigation/radial.vue'
import ButtonUnify from '@/components/ui/Button/ButtonUnify.vue'

const props = defineProps({
  pagination: {
    type: Object,
    default: undefined
  },

  csvOptions: {
    type: Object,
    default: undefined
  },

  onlyExtendDownload: {
    type: Boolean,
    default: false
  },

  extendDownload: {
    type: Array,
    default: () => []
  },

  urlRequest: {
    type: String,
    default: ''
  },

  objectType: {
    type: String,
    default: undefined
  },

  selectedIds: {
    type: Array,
    default: undefined
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
    default: () => []
  },

  append: {
    type: Boolean,
    default: false
  },

  radialLinker: {
    type: Boolean,
    default: true
  },

  radialMassAnnotator: {
    type: Boolean,
    default: true
  },

  radialFilter: {
    type: Boolean,
    default: true
  },

  radialNavigator: {
    type: Boolean,
    default: true
  },

  buttonUnify: {
    type: Boolean,
    default: true
  }
})

const preferences = reactive({
  activeFilter: true,
  activeJSONRequest: false,
  showTable: true
})

const emit = defineEmits([
  'reset',
  'filter',
  'nextpage',
  'per',
  'update:modelValue',
  'update:append'
])

const selectedItems = computed(() =>
  props.selectedIds?.length
    ? props.list.filter((item) => props.selectedIds.includes(item.id))
    : props.list
)

const appendValue = computed({
  get: () => props.append,
  set: (value) => emit('update:append', value)
})

const parameters = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const perValue = computed({
  get: () => parameters.value.per,
  set: (value) => {
    parameters.value.per = value
    emit('per', value)
  }
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
  'Filter task'
)
TW.workbench.keyboard.createLegend(`${platformKey()}+r`, 'Reset', 'Filter task')

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
  grid-template-columns: 400px 1fr;
  gap: 1em;
}
</style>
