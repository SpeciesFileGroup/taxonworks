<template>
  <section-panel
    :status="status"
    :title="title"
    :spinner="loadState.biologicalAssociations"
    menu
    @menu="setModalView(true)"
  >
    <BiologicalAssociationsList :list="filteredList" />
    <VModal
      v-if="showModal"
      @close="setModalView(false)"
      :containerStyle="{ width: '900px' }"
    >
      <template #header>
        <h3>Filter</h3>
      </template>
      <template #body>
        <div class="horizontal-left-content align-start">
          <div class="full_width margin-small-right">
            <h4>Year</h4>
            <year-picker
              :years="citationYears"
              v-model="yearFilter"
            />
          </div>
          <div class="full_width margin-left-margin">
            <h4>Relations</h4>
            <filter-list
              class="overflow-y-scroll"
              :list="relationList"
              v-model="relationsFilter"
            />
          </div>
          <div class="full_width margin-left-margin">
            <h4>Otus</h4>
            <filter-list
              class="overflow-y-scroll"
              :list="otusList"
              v-model="otusFilter"
            />
          </div>
        </div>
        <div class="full_width margin-left-margin">
          <h4>Sources</h4>
          <filter-list
            class="overflow-y-scroll"
            :list="sourcesList"
            v-model="sourcesFilter"
          />
        </div>
      </template>
    </VModal>
  </section-panel>
</template>

<script>
import SectionPanel from './shared/sectionPanel'
import extendSection from './shared/extendSections'
import VModal from 'components/ui/Modal'
import YearPicker from './timeline/TimelineYearsPick.vue'
import FilterList from './biologicalAssociations/filterList'
import BiologicalAssociationsList from './biologicalAssociations/BiologicalAssociationsTable.vue'
import { getUnique, sortArray } from 'helpers/arrays.js'
import { GetterNames } from '../store/getters/getters'

export default {
  mixins: [extendSection],
  components: {
    SectionPanel,
    VModal,
    YearPicker,
    FilterList,
    BiologicalAssociationsList
  },
  computed: {
    biologicalAssociations() {
      return this.$store.getters[GetterNames.GetBiologicalAssociations]
    },
    citationYears() {
      const years = [].concat(
        ...this.biologicalAssociations.map((biological) =>
          biological.citations.map((citation) => citation.source.year)
        )
      )
      return years.reduce(
        (prev, cur) => Object.assign(prev, { [cur]: (prev[cur] | 0) + 1 }),
        {}
      )
    },
    filteredList() {
      return this.biologicalAssociations.filter(
        (biological) =>
          (this.yearFilter
            ? biological.citations.some(
                (citation) => citation.source.year === this.yearFilter
              )
            : true) &&
          (!this.otusFilter.length ||
            this.otusFilter.includes(biological.subjectId) ||
            this.otusFilter.includes(biological.objectId)) &&
          (!this.relationsFilter.length ||
            this.relationsFilter.includes(
              biological.biologicalRelationshipId
            )) &&
          this.checkExist(this.sourcesFilter, biological.citations, 'source_id')
      )
    },
    relationList() {
      return getUnique(
        this.biologicalAssociations.map((item) => ({
          id: item.biologicalRelationshipId,
          label: item.biologicalRelationship
        })),
        'id'
      )
    },
    otusList() {
      return sortArray(
        getUnique(
          [].concat(
            ...this.biologicalAssociations.map((item) => [
              { label: item.subjectLabel, id: item.subjectId },
              {
                label: item.objectTag,
                objectLabel: item.objectLabel,
                id: item.objectId
              }
            ])
          ),
          'id'
        ),
        'objectLabel'
      )
    },
    sourcesList() {
      return sortArray(
        getUnique(
          [].concat(
            ...this.biologicalAssociations.map((biological) =>
              biological.citations.map((citation) => ({
                label: citation.source.object_tag,
                id: citation.source_id
              }))
            )
          ),
          'id'
        ),
        'label'
      )
    }
  },
  data() {
    return {
      showModal: false,
      yearFilter: undefined,
      otusFilter: [],
      relationsFilter: [],
      sourcesFilter: [],
      radioBelow: 7
    }
  },
  methods: {
    setModalView(value) {
      this.showModal = value
    },
    checkExist(filterList, item, property) {
      if (Array.isArray(filterList)) {
        return filterList.length
          ? Array.isArray(item)
            ? item.find((obj) => filterList.includes(obj[property]))
            : filterList.includes(item[property])
          : true
      } else {
        return Array.isArray(item)
          ? item.find((obj) => filterList === obj[property])
          : filterList === item[property]
      }
    }
  }
}
</script>
