<template>
  <div id="vue-task-browse-asserted-distribution-otu">
    <div class="flex-separate middle">
      <h1>Browse asserted distributions</h1>
      <ul class="context-menu">
        <li>
          <label>
            <input
              type="checkbox"
              v-model="activeFilter"
            />
            Show filter
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="activeJSONRequest"
            />
            Show JSON Request
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="append"
            />
            Append results
          </label>
        </li>
      </ul>
    </div>
    <div
      v-show="activeJSONRequest"
      class="panel content separate-bottom"
    >
      <div class="flex-separate middle">
        <span> JSON Request: {{ urlRequest }} </span>
      </div>
    </div>

    <div class="horizontal-left-content align-start">
      <FilterComponent
        class="separate-right filter"
        v-show="activeFilter"
        @url-request="(url) => (urlRequest = url)"
        @result="(list) => loadList(list)"
        @reset="resetTask"
      />
      <div class="full_width">
        <div class="panel container">
          <VMap
            :lat="0"
            :lng="0"
            :zoom="1"
            width="100%"
            height="80vh"
            :geojson="geojson"
            :resize="true"
          />
        </div>
        <ListComponent
          :list="assertedDistribution"
        />
        <h3
          v-if="alreadySearch && !assertedDistribution.length"
          class="subtle middle horizontal-center-content"
        >
          No records found.
        </h3>
      </div>
    </div>
  </div>
</template>

<script setup>
import VMap from '@/components/georeferences/map.vue'
import FilterComponent from './components/filter.vue'
import ListComponent from './components/list.vue'
import { computed, ref } from 'vue'

const EMBED = ['shape', 'level_names']
const EXTEND = [
  'citations',
  'asserted_distribution_shape',
  'origin_citation',
  'shape',
  'source',
  'asserted_distribution_object'
]

const geojson = computed(() => {
  return assertedDistribution.value.map(
    (item) => item.asserted_distribution_shape.shape
  )
})

const assertedDistribution = ref([])
const urlRequest = ref('')
const activeFilter = ref(true)
const activeJSONRequest = ref(false)
const append = ref(false)
const alreadySearch = ref(false)

function resetTask() {
  alreadySearch.value = false
  urlRequest.value = ''
  assertedDistribution.value = []
}

function loadList(newList) {
  if (append.value) {
    let concat = newList.concat(assertedDistribution.value)
    concat = concat.filter(
      (item, index, self) =>
        index === self.findIndex((i) => i.id === item.id)
    )
    assertedDistribution.value = concat
  } else {
    assertedDistribution.value = newList
  }
  alreadySearch.value = true
}
</script>
<style lang="scss">
#vue-task-browse-asserted-distribution-otu {
  .header-box {
    height: 30px;
  }
  .filter {
    width: 400px;
    min-width: 400px;
  }
  :deep(.vue-autocomplete-input) {
    width: 100%;
  }
}
</style>
