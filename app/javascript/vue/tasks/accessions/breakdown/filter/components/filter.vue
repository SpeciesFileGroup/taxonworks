<template>
  <div
    class="panel vue-filter-container"
    v-hotkey="shortcuts"
  >
    <div class="flex-separate content middle action-line">
      <span>Filter</span>
      <button
        type="button"
        data-icon="w_reset"
        class="button circle-button button-default center-icon no-margin"
        @click="resetFilter"
      />
    </div>

    <div class="content">
      <button
        class="button button-default normal-input full_width margin-medium-bottom"
        type="button"
        @click="handleSearch"
      >
        Search
      </button>

      <user-component
        class="margin-large-bottom"
        v-model="params.user"
      />

      <WithComponent
        class="margin-large-bottom"
        v-for="(_, key) in params.with"
        :key="key"
        :title="withTitles[key] || key"
        :param="key"
        v-model="params.with[key]"
      />
    </div>
  </div>
</template>

<script setup>

import UserComponent from 'tasks/collection_objects/filter/components/filters/user'
import platformKey from 'helpers/getPlatformKey.js'
import WithComponent from 'tasks/sources/filter/components/filters/with'
import { removeEmptyProperties } from 'helpers/objects'
import { computed, ref } from 'vue'

const withTitles = {
  with_buffered_determinations: 'Buffered determinations',
  with_buffered_collecting_event: 'Buffered collecting event',
  with_buffered_other_labels: 'Buffered other labels'
}

const emit = defineEmits([
  'parameters',
  'reset'
])

const shortcuts = computed(() => {
  const keys = {}

  keys[`${platformKey()}+r`] = resetFilter
  keys[`${platformKey()}+f`] = handleSearch

  return keys
})

const parseParams = computed(() =>
  removeEmptyProperties({
    ...params.value.base,
    ...params.value.with,
    ...filterEmptyParams(params.value.user)
  })
)

const resetFilter = () => {
  emit('reset')
  params.value = initParams()
}

const initParams = () => ({
  base: {
  },
  with: {
    identifiers: undefined,
    collecting_event: undefined,
    taxon_determinations: undefined,
    with_buffered_determinations: undefined,
    with_buffered_collecting_event: undefined,
    with_buffered_other_labels: undefined
  },
  user: {
    user_id: undefined,
    user_target: undefined,
    user_date_start: undefined,
    user_date_end: undefined
  }
})

const params = ref(initParams())

const handleSearch = () => {
  emit('parameters', parseParams.value)
}

const filterEmptyParams = object => {
  const keys = Object.keys(object)

  keys.forEach(key => {
    if (object[key] === '') {
      delete object[key]
    }
  })
  return object
}

</script>
<style scoped>
:deep(.btn-delete) {
  background-color: #5D9ECE;
}
</style>
