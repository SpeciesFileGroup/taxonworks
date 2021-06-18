<template>
  <section-panel
    :status="status"
    :title="title"
    :spinner="isLoading"
    menu
    @menu="showModal = true">
    <div class="switch-radio separate-top separate-bottom">
      <template
        v-for="(item, index) in filterTabs"
        :key="index">
        <input
          v-model="tabSelected"
          :id="`switch-filter-nomenclature-${index}`"
          name="switch-filter-nomenclature-options"
          type="radio"
          class="normal-input button-active"
          :value="item"> 
        <label :for="`switch-filter-nomenclature-${index}`">{{ item.label }}</label>
      </template>
    </div>
    <div :class="Object.assign({}, ...(preferences.filterSections.show.concat(preferences.filterSections.topic)).map(item => ({ [item.key]: !item.value })))">
      <timeline-citations :citations="filteredList"/>
      <h3>References</h3>
      <ul
        v-if="nomenclature"
        class="no_bullets">
        <template
          v-if="selectedReferences.length">
          <template
            v-for="item in references"
            :key="item"
          >
            <li
              v-show="filterSource(nomenclature.sources.list[item])">
              <label>
                <input
                  v-model="references"
                  :value="item"
                  type="checkbox">
                <span v-html="nomenclature.sources.list[item].cached"/>
              </label>
            </li>
          </template>
        </template>
        <template v-else>
          <template
            v-for="(item, key) in nomenclature.sources.list"
            :key="key">
            <li v-show="filterSource(item)">
              <label>
                <input
                  v-model="references"
                  :value="key"
                  type="checkbox">
                <span v-html="item.cached"/>
              </label>
              <template v-if="showReferencesTopic">
                <span
                  v-for="(topic, index) in getSourceTopics(item).map(key => nomenclature.topics.list[key])"
                  class="pill topic references_topics"
                  :key="index"
                  :style="{ 'background-color': topic.css_color }"
                  v-html="topic.name"/>
              </template>
            </li>
          </template>
        </template>
      </ul>
    </div>
    <soft-validation-modal/>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <template #header>
        <h3>Visualize</h3>
      </template>
      <template #body>
        <div class="flex-separate">
          <div class="full_width">
            <h4 class="capitalize separate-bottom">Time</h4>
            <ul class="no_bullets">
              <li
                class="separate-right"
                v-for="(item, key) in preferences.filterSections.and.time"
                :key="key">
                <label>
                  <input
                    v-model="item.value"
                    type="checkbox"/>
                  {{ item.label }}
                </label>
              </li>
            </ul>
            <h4 class="capitalize separate-bottom">Year</h4>
            <year-picker
              v-model.number="preferences.filterSections.and.year[0].value"
              :years="nomenclature.sources.year_metadata"/>
          </div>
          <div class="full_width">
            <h4 class="capitalize separate-bottom">Filter</h4>
            <ul class="no_bullets">
              <li
                class="separate-right"
                v-for="(item, key) in preferences.filterSections.and.current"
                :key="key">
                <label>
                  <input
                    v-model="item.value"
                    type="checkbox"/>
                  {{ item.label }}
                </label>
              </li>
            </ul>
            <template v-for="section in preferences.filterSections.or">
              <ul class="no_bullets">
                <li
                  v-for="(item, key) in section"
                  :key="key"
                  class="separate-right">
                  <label>
                    <input
                      v-model="item.value"
                      type="checkbox"/>
                    {{ item.label }}
                  </label>
                </li>
              </ul>
            </template>
          </div>
          <div class="full_width">
            <h4 class="capitalize separate-bottom">Show</h4>
            <ul class="no_bullets">
              <li
                class="separate-right"
                v-for="(item, key) in preferences.filterSections.show"
                :key="key">
                <label>
                  <input
                    v-model="item.value"
                    type="checkbox"/>
                  {{ item.label }}
                </label>
              </li>
            </ul>
            <h4 class="capitalize separate-bottom">Topic</h4>
            <ul class="no_bullets">
              <li
                v-for="(item, key) in preferences.filterSections.topic"
                :key="key">
                <label>
                  <input
                    v-model="item.value"
                    type="checkbox"/>
                  {{ item.label }}
                </label>
              </li>
              <li>
                <label>
                  <input
                    v-model="showReferencesTopic"
                    type="checkbox"/>
                  On references
                </label>
              </li>
            </ul>
          </div>
          <div>
            <div class="separate-bottom"></div>
            <ul
              class="no_bullets topic-section">
              <li
                v-for="(topic, key) in nomenclature.topics.list"
                :key="key">
                <label>
                  <input
                    type="checkbox"
                    :value="key"
                    v-model="topicsSelected">
                  {{ topic.name }}
                </label>
              </li>
            </ul>
          </div>
        </div>
      </template>
    </modal-component>
  </section-panel>
</template>

<script>

import SectionPanel from '../shared/sectionPanel'
import ModalComponent from 'components/ui/Modal'
import YearPicker from './TimelineYearsPick.vue'
import extendSection from '../shared/extendSections'
import SoftValidationModal from '../softValidationModal'
import TimelineCitations from './TimelineCitations.vue'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { Otu } from 'routes/endpoints'

export default {
  mixins: [extendSection],
  components: {
    SectionPanel,
    ModalComponent,
    YearPicker,
    SoftValidationModal,
    TimelineCitations
  },
  computed: {
    selectedReferences () {
      return this.references.map(item => this.nomenclature.sources.list[item])
    },
    itemsList () {
      return this.references.length
        ? this.nomenclature.items.filter(item =>
          this.selectedReferences.find(ref => ref.objects.includes(item.data_attributes['history-object-id']))
        )
        : this.nomenclature.items
    },
    preferences: {
      get () {
        return this.$store.getters[GetterNames.GetPreferences]
      },
      set (value) {
        this.$store.commit(MutationNames.SetPreferences, value)
      }
    },
    filteredList () {
      return Array.isArray(this.itemsList) ? this.itemsList.filter(item => this.checkFilter(item)) : []
    }
  },
  data () {
    return {
      isLoading: true,
      showReferencesTopic: false,
      references: [],
      topicsSelected: [],
      showModal: false,
      nomenclature: '',
      tabSelected: {
        label: 'All',
        key: '',
        value: ''
      },
      hideInfo: [],
      filterTabs: [
        {
          label: 'All',
          key: '',
          value: ''
        },
        {
          label: 'Nomenclature',
          key: 'history-origin',
          value: 'otu',
          equal: false
        },
        {
          label: 'Protonym',
          key: 'history-origin',
          value: 'protonym'
        },
        {
          label: 'OTU (biology)',
          key: 'history-origin',
          value: 'otu'
        }
      ]
    }
  },
  watch: {
    otu: {
      handler (newVal) {
        if (newVal) {
          this.isLoading = true
          Otu.timeline(this.otu.id).then(response => {
            this.nomenclature = response.body
            this.isLoading = false
          })
        }
      },
      immediate: true
    }
  },
  methods: {
    checkFilter (item) {
      const keysAND = Object.keys(this.preferences.filterSections.and)
      const keysOR = Object.keys(this.preferences.filterSections.or)

      return (((!this.tabSelected?.equal ||
        this.tabSelected.equal
        ? item.data_attributes[this.tabSelected.key] === this.tabSelected.value
        : item.data_attributes[this.tabSelected.key] !== this.tabSelected.value) ||
        (this.tabSelected.label === 'All')) &&
        keysAND.every(key => {
          if ((this.preferences.filterSections.and[key].every(filter => filter.value === false))) return true

          return this.preferences.filterSections.and[key].every(filter => {
            if (filter.value === undefined) return true
            return (filter.equal
              ? item.data_attributes[filter.key] === filter.value
              : item.data_attributes[filter.key] !== filter.value)
          })
        }) &&
        keysOR.every(key =>
          this.preferences.filterSections.or[key].some(filter =>
            filter.equal
              ? item.data_attributes[filter.key] === filter.value
              : item.data_attributes[filter.key] !== filter.value
          )
        ) &&
        (this.topicsSelected.length
          ? item.topics.some(topic => this.topicsSelected.includes(topic))
          : true))
    },

    filterSource (source) {
      const globalIds = source.objects

      return (this.itemsList.filter(item => this.checkFilter(item)).find(item => globalIds.includes(item.data_attributes['history-object-id'])))
    },

    getSourceTopics (source) {
      const globalIds = source.objects
      const topics = this.itemsList.filter(item => this.checkFilter(item))
        .filter(item => globalIds.includes(item.data_attributes['history-object-id']))
        .map(item => item.topics)

      return [...new Set([].concat(...topics))]
    }
  }
}
</script>
<style lang="scss" scoped>
  .hidden {
    display: none;
  }
  :deep(.modal-container) {
    width: 900px;
  }
  .topic-section {
    overflow-y: scroll;
    max-height: 480px;
  }
  li {
    margin-top: 4px;
  }
  .references_topics {
    color: black;
  }
  :deep(.annotation__note) {
    display: inline;
  }
  :deep(.hide-validations) {
    .soft_validation_anchor {
      display: none !important;
    }
  }
  :deep(.hide-notes) {
    .history__citation_notes {
      display: none !important;
    }
  }
  :deep(.hide-topics) {
    .history__citation_topics {
      display: none !important;
    }
  }
</style>
