<template>
  <NavBar>
    <div class="middle grid-filter__nav">
      <div class="flex-separate middle">
        <VBtn
          color="primary"
          medium
          @click="emit('filter')"
        >
          Filter
        </VBtn>
        <ModalNestedParameters
          :parameters="parameters"
        />
        <ul class="no_bullets context-menu">
          <li v-if="objectType">
            <RadialFilter
              :parameters="parameters"
              :object-type="objectType"
            />
          </li>
          <li>
            <VBtn
              circle
              medium
              color="primary"
              @click="emit('reset')"
            >
              <VIcon
                name="reset"
                small
              />
            </VBtn>
          </li>
        </ul>
      </div>
      <span>|</span>
      <div
        class="flex-separate"
        v-if="pagination"
      >
        <pagination-component
          v-if="pagination"
          :pagination="pagination"
          @next-page="emit('nextpage', $event)"
        />
        <pagination-count
          :pagination="pagination"
          v-model="perValue"
        />
      </div>
      <slot name="nav-right" />
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

  parameters: {
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
  }
})

const emit = defineEmits([
  'reset',
  'filter',
  'nextpage',
  'update:per',
  'update:modelValue'
])

const perValue = computed({
  get: () => props.per,
  set: value => emit('update:per', value)
})

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const hotkeys = ref([
  {
    keys: [platformKey(), 'f'],
    preventDefault: true,
    handler () {
      emit('filter')
    }
  },
  {
    keys: [platformKey(), 'r'],
    preventDefault: true,
    handler () {
      emit('reset')
    }
  }
])

TW.workbench.keyboard.createLegend(`${platformKey()}+f`, 'Search', 'Filter sources')
TW.workbench.keyboard.createLegend(`${platformKey()}+r`, 'Reset task', 'Filter sources')

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
  background-color: #5D9ECE;
}
</style>
