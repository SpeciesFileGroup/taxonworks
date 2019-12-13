<template>
  <section-panel
    title="Timeline"
    :spinner="isLoading"
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
    <div>
      <h3>Citations</h3>
      <ul class="taxonomic_history">
        <li 
          v-for="item in itemsList"
          v-if="checkFilter(item)">
          <span v-html="item.label_html"/>
        </li>
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
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Visualize</h3>
      <div
        class="flex-separate"
        slot="body">
        <div>
          <h4 class="capitalize separate-bottom">Time</h4>
          <ul class="no_bullets">
            <li
              class="separate-right"
              v-for="(item, key) in filterSections.time"
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
            v-model.number="filterSections.year[0].value"
            :years="nomenclature.sources.year_metadata"/>
        </div>
        <div>
          <h4 class="capitalize separate-bottom">Filter</h4>
          <ul class="no_bullets">
            <li
              v-for="(item, key) in filterSections.filter"
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
        </div>
        <div>
          <h4 class="capitalize separate-bottom">Show</h4>
          <ul class="no_bullets">
            <li
              class="separate-right"
              v-for="(item, key) in filterSections.show"
              :key="key">
              <label>
                <input
                  v-model="item.value"
                  type="checkbox"/>
                {{ item.label }}
              </label>
            </li>
          </ul>
        </div>
        <div>
          <h4 class="capitalize separate-bottom">Topic</h4>
          <ul class="no_bullets">
            <li
              v-for="(item, key) in filterSections.topic"
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
                References
              </label>
            </li>
          </ul>
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
import SwitchComponent from 'components/switch'
import ModalComponent from 'components/modal'
import YearPicker from './nomenclature/yearsPick'

export default {
  components: {
    SectionPanel,
    SwitchComponent,
    ModalComponent,
    YearPicker
  },
  props: {
    otu: {
      type: Object
    }
  },
  computed: {
    selectedReferences () {
      return this.references.map(item => { return this.nomenclature.sources.list[item] })
    },
    itemsList () {
      return this.references.length ? this.nomenclature.items.filter(item => {
        return this.selectedReferences.find(ref => { return ref.objects.includes(item.data_attributes['history-object-id']) })
      }) : this.nomenclature.items
    }
  },
  data() {
    return {
      isLoading: true,
      showReferencesTopic: false,
      references: [],
      topicsSelected: [],
      showModal: false,
      filterSections: {
        time: [
          {
            label: 'First',
            key: 'history-is-first',
            value: true,
            attribute: true,
            equal: true
          },
          {
            label: 'Last',
            key: 'history-is-last',
            value: true,
            attribute: true,
            equal: true
          }
        ],
        year: [{
          label: 'Year',
          key: 'history-year',
          value: undefined,
          attribute: true,
          equal: true
        }],
        filter: [
          {
            label: 'Valid',
            key: 'history-is-valid',
            value: true,
            attribute: true,
            equal: true
          },
          {
            label: 'Invalid',
            key: 'history-is-valid',
            value: true,
            attribute: true,
            equal: false
          },
          {
            label: 'Cited',
            key: 'history-is-cited',
            value: true,
            equal: true
          },
          {
            label: 'Uncited',
            key: 'history-is-cited',
            value: true,
            equal: false
          }
        ],
        show: [
          {
            label: 'Notes',
            key: '.annotation__note',
            value: true
          },
          {
            label: 'Soft validation',
            key: '.soft_validation_anchor',
            value: true
          }
        ],
        topic: [
          {
            label: 'Citations',
            key: '.history__citation_topics',
            value: true
          }
        ],
      },
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
        if(newVal) {
          this.isLoading = true
          GetNomenclatureHistory(this.otu.id).then(response => {
            this.nomenclature = response.body
            this.isLoading = false
          })
        }
      },
      immediate: true
    },
    filterSections: {
      handler (newVal) {
        const keys = Object.keys(newVal)
        keys.forEach(key => {
          newVal[key].forEach(item => {
            document.querySelectorAll(item.key).forEach(element => {
              item.value ? element.classList.remove('hidden') : element.classList.add('hidden')
            })
          })
        })
      },
      deep: true
    }
  },
  methods: {
    checkFilter (item) {
      const keys = Object.keys(this.filterSections)
      return ((!this.tabSelected.hasOwnProperty('equal') || 
        this.tabSelected.equal ?
        item.data_attributes[this.tabSelected.key] === this.tabSelected.value : 
        item.data_attributes[this.tabSelected.key] != this.tabSelected.value) || 
        (this.tabSelected.label === 'All')) && 
        keys.every(key => {
          return this.filterSections[key].every(filter => {
            if (filter.value === undefined || filter.value == true) return true
            return !filter.hasOwnProperty('attribute') || filter.attribute ? 
            (filter.hasOwnProperty('equal') && filter.equal ? 
            item.data_attributes[filter.key] === filter.value : 
            item.data_attributes[filter.key] !== filter.value) : true
          })
        }) && 
        (this.topicsSelected.length ? item.topics.some(topic => {
          return this.topicsSelected.includes(topic)
        }) : true)
    },
    filterSource(source) {
      let globalIds = source.objects
      return (this.itemsList.filter(item => { return this.checkFilter(item) }).find(item => {
        return globalIds.includes(item.data_attributes['history-object-id']) 
      }) != undefined)
    },
    getSourceTopics(source) {
      let globalIds = source.objects
      let topics = []
      topics = this.itemsList.filter(item => { return this.checkFilter(item) }).filter(item => { return globalIds.includes(item.data_attributes['history-object-id']) }).map(item => {
        return item.topics
      })
      return [...new Set([].concat(...topics))]
    }
  }
}
</script>
<style scoped>
  .hidden {
    display: none;
  }
  /deep/ .modal-container {
    width: 800px;
  }
  .topic-section {
    overflow-y: scroll;
    max-height: 480px;
  }
  li {
    margin-top: 4px;
  }
</style>