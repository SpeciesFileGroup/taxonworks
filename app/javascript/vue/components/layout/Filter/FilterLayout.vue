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
  <div class="grid-filter">
    <div
      v-if="filter"
      class="grid-filter__facets"
    >
      <slot name="facets">
        <component
          v-for="(facet, index) in facets"
          :key="index"
          :is="facet.component"
          v-bind="facet.props"
          v-model="parameters"
        />
      </slot>
    </div>

    <slot name="table" />
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
import { ref, computed } from 'vue'

const props = defineProps({
  filter: {
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

const parameters = computed({
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

const stop = useHotkey(hotkeys.value)

</script>

<style scoped>

.grid-filter {
  display: grid;
  gap: 1em;
  grid-template-columns: 400px 1fr;
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
