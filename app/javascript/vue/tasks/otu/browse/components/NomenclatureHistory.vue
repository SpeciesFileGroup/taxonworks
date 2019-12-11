<template>
  <section-panel
    title="Timeline"
    @menu="showModal = true">
    <div class="switch-radio separate-top">
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

    <div class="horizontal-left-content separate-top">
      <div
        v-for="item in hideInfo"
        :key="item.key"
        class="separate-right">
        <label>
          <input
            v-model="item.value"
            type="checkbox"/>
          {{ item.label }}
        </label>
      </div>
    </div>
    <div>
      <h3>Citations</h3>
      <ul class="taxonomic_history">
        <li 
          v-for="item in nomenclature.items"
          v-show="checkFilter(item)">
          <span v-html="item.label_html"/>
        </li>
      </ul>
      <h3>References</h3>
      <ul class="taxonomic_history">
        <template v-for="source in nomenclature.sources">
        <li 
          v-for="item in source"
          v-show="filterSource(source)">
          <span v-html="item.cached"/>
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
        <div
          v-for="(section, key) in filterSections"
          :key="key">
          <h4 class="capitalize separate-bottom">{{ key }}</h4>
          <ul class="no_bullets">
            <li
              v-for="item in section"
              :key="item.key"
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
      </div>
    </modal-component>
  </section-panel>
</template>

<script>

import SectionPanel from './shared/sectionPanel'
import { GetNomenclatureHistory } from '../request/resources.js'
import SwitchComponent from 'components/switch'
import ModalComponent from 'components/modal'

export default {
  components: {
    SectionPanel,
    SwitchComponent,
    ModalComponent
  },
  props: {
    otu: {
      type: Object
    }
  },
  data() {
    return {
      showModal: false,
      filterSections: {
        time: [
          {
            label: 'First',
            key: 'history-is-first',
            value: true,
            attribute: true
          },
          {
            label: 'End',
            key: 'history-is-last',
            value: true,
            attribute: true
          }
        ],
        metadata: [
          {
            label: 'Notes',
            key: '.annotation__note',
            value: true
          },
          {
            label: 'Soft validation',
            key: '.soft_validation_anchor',
            value: true
          },
          {
            label: 'Valid',
            key: 'history-is-valid',
            value: true,
            attribute: true
          },
          {
            label: 'Invalid',
            key: 'history-is-invalid',
            value: true,
            attribute: true
          },
          {
            label: 'Cited',
            key: 'data-is-cited',
            value: true
          }
        ],
        topic: [
          {
            label: 'Show',
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
      ],
      current: false
    }
  },
  watch: {
    otu: {
      handler (newVal) {
        if(newVal) {
          GetNomenclatureHistory(this.otu.id).then(response => {
            this.nomenclature = response.body
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
      return ((!this.tabSelected.hasOwnProperty('equal') && 
        this.tabSelected.equal ?
        item.data_attributes[this.tabSelected.key] === this.tabSelected.value : 
        item.data_attributes[this.tabSelected.key] != this.tabSelected.value) || 
        (this.tabSelected.label === 'All')) && 
        keys.every(key => {
          return this.filterSections[key].every(filter => {
            return filter.hasOwnProperty('attribute') || filter.attribute ? item.data_attributes[filter.key] !== filter.value : true
          })
        })
    },
    filterSource(source) {
      let globalIds = source[Object.keys(source)[0]].objects
      return this.nomenclature.items.find(item => {
        if (this.checkFilter(item)) {
          return globalIds.includes(item.data_attributes['history-object-id'])
        }
      })
    }
  }
}
</script>
<style scoped>
  .hidden {
    display: none;
  }
</style>