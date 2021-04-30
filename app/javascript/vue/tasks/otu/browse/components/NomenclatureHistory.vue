<template>
  <section-panel
    :status="status"
    :title="title"
    :spinner="isLoading"
    menu
    @menu="showModal = true">
    <div class="switch-radio separate-top separate-bottom">
      <template v-for="(item, index) in filterTabs">
        <input
          v-model="tabSelected"
          :id="`switch-filter-nomenclature-${index}`"
          :key="index"
          name="switch-filter-nomenclature-options"
          type="radio"
          class="normal-input button-active"
          :value="item"> 
        <label :for="`switch-filter-nomenclature-${index}`">{{ item.label }}</label>
      </template>
    </div>
    <div :class="Object.assign({}, ...(preferences.filterSections.show.concat(preferences.filterSections.topic)).map(item => { return { [item.key]: !item.value } }))">
      <h3>Citations ({{ filteredList.length }})</h3>
      <ul class="taxonomic_history">
        <template v-for="item in filteredList">
          <li v-if="item.label_html">
            <span v-html="item.label_html"/>
          </li>
        </template>
      </ul>
      <h3>References</h3>
      <ul
        v-if="nomenclature"
        class="no_bullets">
        <template
          v-if="selectedReferences.length">
          <li
            v-for="item in references"
            :key="item"
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
        <template 
          v-else
          v-for="(item, key) in nomenclature.sources.list">
          <li
            :key="key"
            v-show="filterSource(item)">
            <label>
              <input
                v-model="references"
                :value="key"
                type="checkbox">
              <span v-html="item.cached"/>
            </label>
            <template v-if="showReferencesTopic">
              <span
                v-for="(topic, index) in getSourceTopics(item).map(key => { return nomenclature.topics.list[key] })"
                class="pill topic references_topics"
                :key="index"
                :style="{ 'background-color': topic.css_color }"
                v-html="topic.name"/>
            </template>
          </li>
        </template>
      </ul>
    </div>
    <soft-validation-modal/>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Visualize</h3>
      <div
        class="flex-separate"
        slot="body">
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
    </modal-component>
  </section-panel>
</template>

<script>

import SectionPanel from './shared/sectionPanel'
import { GetNomenclatureHistory } from '../request/resources.js'
import ModalComponent from 'components/modal'
import YearPicker from './nomenclature/yearsPick'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import extendSection from './shared/extendSections'
import SoftValidationModal from './softValidationModal'

export default {
  mixins: [extendSection],
  components: {
    SectionPanel,
    ModalComponent,
    YearPicker,
    SoftValidationModal
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
          GetNomenclatureHistory(this.otu.id).then(response => {
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
        : item.data_attributes[this.tabSelected.key] != this.tabSelected.value) ||
        (this.tabSelected.label === 'All')) &&
        keysAND.every(key => {
          if ((this.preferences.filterSections.and[key].every(filter => { return filter.value === false }))) return true
          return this.preferences.filterSections.and[key].every(filter => {
            if (filter.value === undefined) return true
            return (filter.equal
              ? item.data_attributes[filter.key] === filter.value
              : item.data_attributes[filter.key] !== filter.value)
          })
        }) &&
        keysOR.every(key => {
          return this.preferences.filterSections.or[key].some(filter => {
            return (filter.equal 
              ? item.data_attributes[filter.key] === filter.value
              : item.data_attributes[filter.key] !== filter.value)
          })
        }) &&
        (this.topicsSelected.length
          ? item.topics.some(topic => this.topicsSelected.includes(topic))
          : true))
    },
    filterSource (source) {
      let globalIds = source.objects
      return (this.itemsList.filter(item => { return this.checkFilter(item) }).find(item => {
        return globalIds.includes(item.data_attributes['history-object-id'])
      }) != undefined)
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
  ::v-deep .modal-container {
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
  ::v-deep .annotation__note {
    display: inline;
  }
  ::v-deep .hide-validations {
    .soft_validation_anchor {
      display: none !important;
    }
  }
  ::v-deep .hide-notes {
    .history__citation_notes {
      display: none !important;
    }
  }
  ::v-deep .hide-topics {
    .history__citation_topics {
      display: none !important;
    }
  }
</style>
