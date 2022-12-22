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
      class="vue-filter-container"
    >
      <div>
        <slot name="facets" />
      </div>
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
  }
})

const emit = defineEmits([
  'reset',
  'filter',
  'update:per',
  'nextpage'
])

const perValue = computed({
  get: () => props.per,
  set: value => emit('update:per', value)
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
  gap: .5em;
  grid-template-columns: 400px 1fr;
}

.grid-filter__nav {
  display: grid;
  grid-template-columns: 380px 2px 1fr 1fr;
  gap: 1em;
}

.vue-filter-container {
  width: 400px;
  max-width: 400px;
}

:deep(.btn-delete) {
  background-color: #5D9ECE;
}
</style>
