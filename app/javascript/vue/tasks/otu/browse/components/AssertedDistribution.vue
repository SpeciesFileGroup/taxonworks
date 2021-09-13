<template>
  <section-panel
    :status="status"
    :spinner="loadState.assertedDistribution"
    :title="title"
    menu
    @menu="setModalView(true)">
    <template #title>
      <a
        v-if="currentOtu"
        :href="`/tasks/otus/browse_asserted_distributions/index?otu_id=${currentOtu.id}`"
      >Expand</a>
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
          :key="assertedDistribution.id">
          <td>{{ assertedDistribution.geographic_area.level0_name }}</td>
          <td>{{ assertedDistribution.geographic_area.level1_name }}</td>
          <td>{{ assertedDistribution.geographic_area.level2_name }}</td>
          <td>
            <a
              :href="`/asserted_distributions/${assertedDistribution.id}`"
              title="Edit">
              <span v-html="assertedDistribution.geographic_area.name"/>
            </a>
          </td>
          <td>{{ assertedDistribution.geographic_area.geographic_area_type.name }}</td>
          <td>{{ assertedDistribution.is_absent ? '✕' : '✓' }}</td>
          <td>{{ assertedDistribution.geographic_area.shape ? '✓' : '✕' }}</td>
          <td>
            <a
              v-for="citation in assertedDistribution.citations"
              :key="citation.id"
              :href="`/tasks/nomenclature/by_source?source_id=${citation.source.id}`"
              :title="citation.source.cached">
              <span v-html="`${citation.source.author_year}` + `${citation.source.year_suffix}` + (citation.pages ? `:${citation.pages}` : '')"/>&nbsp;
            </a>
          </td>
          <td v-html="assertedDistribution.otu.object_tag"/>
        </tr>
      </tbody>
    </table>
    <modal-component
      v-if="showModal"
      @close="setModalView(false)"
      :containerStyle="{ width: '900px' }">
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
              v-model="level0Filter"/>
          </div>
          <div class="full_width margin-left-margin">
            <h4>Level 1</h4>
            <filter-level
              class="overflow-y-scroll"
              :levels="level1List"
              v-model="level1Filter"/>
          </div>
          <div class="full_width margin-left-margin">
            <h4>Level 2</h4>
            <filter-level
              class="overflow-y-scroll"
              :levels="level2List"
              v-model="level2Filter"/>
          </div>
        </div>
      </template>
    </modal-component>
  </section-panel>
</template>

<script>

import SectionPanel from './shared/sectionPanel'
import ModalComponent from 'components/ui/Modal'
import extendSection from './shared/extendSections'
import { GetterNames } from '../store/getters/getters'
import { getUnique } from 'helpers/arrays'
import FilterLevel from './assertedDistribution/filterLevel'

export default {
  mixins: [extendSection],
  components: {
    ModalComponent,
    SectionPanel,
    FilterLevel
  },
  computed: {
    assertedDistributions () {
      return getUnique(this.$store.getters[GetterNames.GetAssertedDistributions], 'id')
    },
    currentOtu () {
      return this.$store.getters[GetterNames.GetCurrentOtu]
    },
    level0List () {
      return [...new Set(this.assertedDistributions.map(ad => ad.geographic_area.level0_name))].filter(level => level)
    },
    level1List () {
      return [...new Set(this.assertedDistributions.map(ad => ad.geographic_area.level1_name))].filter(level => level)
    },
    level2List () {
      return [...new Set(this.assertedDistributions.map(ad => ad.geographic_area.level2_name))].filter(level => level)
    },
    filteredList () {
      return this.assertedDistributions.filter(ad =>
        ((this.level0Filter.length ? this.level0Filter.includes(ad.geographic_area.level0_name) : true) &&
        (this.level1Filter.length ? this.level1Filter.includes(ad.geographic_area.level1_name) : true) &&
        (this.level2Filter.length ? this.level2Filter.includes(ad.geographic_area.level2_name) : true))
      )
    }
  },
  data () {
    return {
      showModal: false,
      level0Filter: [],
      level1Filter: [],
      level2Filter: []
    }
  },
  methods: {
    setModalView (value) {
      this.showModal = value
    }
  }
}
</script>
