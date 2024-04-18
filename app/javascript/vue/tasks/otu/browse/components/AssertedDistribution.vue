<template>
  <section-panel
    :status="status"
    :spinner="loadState.assertedDistribution"
    :title="title"
    menu
    @menu="setModalView(true)"
  >
    <template #title>
      <a
        v-if="currentOtu"
        :href="`${RouteNames.BrowseAssertedDistribution}?otu_id=${currentOtu.id}`"
        >Expand</a
      >
    </template>
    <table class="full_width">
      <thead>
        <tr>
          <th>Level 0</th>
          <th>Level 1</th>
          <th>Level 2</th>
          <th>Name</th>
          <th>type</th>
          <th>Presence</th>
          <th>Shape</th>
          <th>Citations</th>
          <th>OTU</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="assertedDistribution in filteredList"
          :key="assertedDistribution.id"
        >
          <td>{{ assertedDistribution.geographic_area.level0_name }}</td>
          <td>{{ assertedDistribution.geographic_area.level1_name }}</td>
          <td>{{ assertedDistribution.geographic_area.level2_name }}</td>
          <td>
            <a
              :href="`/asserted_distributions/${assertedDistribution.id}`"
              title="Edit"
            >
              <span v-html="assertedDistribution.geographic_area.name" />
            </a>
          </td>
          <td>
            {{ assertedDistribution.geographic_area.geographic_area_type.name }}
          </td>
          <td>{{ assertedDistribution.is_absent ? '✕' : '✓' }}</td>
          <td>
            {{ assertedDistribution.geographic_area.has_shape ? '✓' : '✕' }}
          </td>
          <td>
            <a
              v-for="citation in assertedDistribution.citations"
              :key="citation.id"
              :href="`/tasks/nomenclature/by_source?source_id=${citation.source_id}`"
              :title="citation.source.object_label"
            >
              <span v-html="citation.citation_source_body" />&nbsp;
            </a>
          </td>
          <td v-html="assertedDistribution.otu.object_tag" />
        </tr>
      </tbody>
    </table>
    <modal-component
      v-if="showModal"
      @close="setModalView(false)"
      :containerStyle="{ width: '900px' }"
    >
      <template #header>
        <h3>Filter</h3>
      </template>
      <template #body>
        <div class="horizontal-left-content align-start">
          <div class="full_width margin-left-margin">
            <h4>Level 0</h4>
            <filter-level
              class="overflow-y-scroll"
              :levels="level0List"
              v-model="level0Filter"
            />
          </div>
          <div class="full_width margin-left-margin">
            <h4>Level 1</h4>
            <filter-level
              class="overflow-y-scroll"
              :levels="level1List"
              v-model="level1Filter"
            />
          </div>
          <div class="full_width margin-left-margin">
            <h4>Level 2</h4>
            <filter-level
              class="overflow-y-scroll"
              :levels="level2List"
              v-model="level2Filter"
            />
          </div>
        </div>
      </template>
    </modal-component>
  </section-panel>
</template>

<script setup>
import SectionPanel from './shared/sectionPanel'
import ModalComponent from '@/components/ui/Modal'
import FilterLevel from './assertedDistribution/filterLevel'
import { GetterNames } from '../store/getters/getters'
import { getUnique } from '@/helpers/arrays'
import { RouteNames } from '@/routes/routes'
import { useStore } from 'vuex'
import { computed, ref } from 'vue'

defineProps({
  status: {
    type: String,
    default: 'unknown'
  },
  title: {
    type: String,
    default: undefined
  },
  otu: {
    type: Object,
    required: true
  }
})

const store = useStore()
const showModal = ref(false)
const level0Filter = ref([])
const level1Filter = ref([])
const level2Filter = ref([])

const loadState = computed(() => store.getters[GetterNames.GetLoadState])

const assertedDistributions = computed(() =>
  getUnique(store.getters[GetterNames.GetAssertedDistributions], 'id')
)

const currentOtu = computed(() => store.getters[GetterNames.GetCurrentOtu])
const level0List = computed(() =>
  [
    ...new Set(
      assertedDistributions.value.map((ad) => ad.geographic_area.level0_name)
    )
  ].filter((level) => level)
)
const level1List = computed(() =>
  [
    ...new Set(
      assertedDistributions.value.map((ad) => ad.geographic_area.level1_name)
    )
  ].filter((level) => level)
)
const level2List = computed(() =>
  [
    ...new Set(
      assertedDistributions.value.map((ad) => ad.geographic_area.level2_name)
    )
  ].filter((level) => level)
)

const filteredList = computed(() => {
  return assertedDistributions.value.filter(
    (ad) =>
      (!level0Filter.value.length ||
        level0Filter.value.includes(ad.geographic_area.level0_name)) &&
      (!level1Filter.value.length ||
        level1Filter.value.includes(ad.geographic_area.level1_name)) &&
      (!level2Filter.value.length ||
        level2Filter.value.includes(ad.geographic_area.level2_name))
  )
})

function setModalView(value) {
  showModal.value = value
}
</script>
