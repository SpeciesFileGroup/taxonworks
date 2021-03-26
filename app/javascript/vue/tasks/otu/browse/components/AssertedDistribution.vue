<template>
  <section-panel
    :status="status"
    :spinner="loadState.assertedDistribution"
    :title="title"
    menu
    @menu="setModalView(true)">
    <a
      v-if="currentOtu"
      :href="`/tasks/otus/browse_asserted_distributions/index?otu_id=${currentOtu.id}`"
      slot="title">Expand</a>
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
          <td>{{ assertedDistribution.geographic_area.name }}</td>
          <td>{{ assertedDistribution.geographic_area.geographic_area_type.name }}</td>
          <td>{{ assertedDistribution.is_absent ? '✕' : '✓' }}</td>
          <td>{{ assertedDistribution.geographic_area.geo_json ? '✓' : '✕' }}</td>
          <td v-html="assertedDistribution.citations.map(citation => (`${citation.source.author_year}` + (citation.pages ? `:${citation.pages}` : ''))).sort().join('; ')"/>
          <td v-html="assertedDistribution.otu.object_tag"/>
        </tr>
      </tbody>
    </table>
    <modal-component
      v-if="showModal"
      @close="setModalView(false)"
      :containerStyle="{ width: '900px' }">
      <h3 slot="header">Filter</h3>
      <div slot="body">
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
      </div>
    </modal-component>
  </section-panel>
</template>

<script>

import SectionPanel from './shared/sectionPanel'
import ModalComponent from 'components/modal'
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
