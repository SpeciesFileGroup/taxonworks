<template>
  <section-panel title="Timeline">
    <switch-component
      class="separate-top"
      :options="tabs"
      v-model="view"/>
    <div class="horizontal-left-content separate-top">
      <div
        v-for="item in filter"
        :key="item.key"
        class="separate-right">
        <label>
          <input
            v-model="filterSelected"
            :value="item"
            type="checkbox"/>
          {{ item.label }}
        </label>
      </div>
      <div class="separate-right">
        <label>
          <input
            v-model="current"
            type="checkbox"/>
          Current
        </label>
      </div>
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
  </section-panel>
</template>

<script>

import SectionPanel from './shared/sectionPanel'
import { GetNomenclatureHistory } from '../request/resources.js'
import SwitchComponent from 'components/switch'

export default {
  components: {
    SectionPanel,
    SwitchComponent
  },
  props: {
    otu: {
      type: Object
    }
  },
  data() {
    return {
      tabs: ['All', 'Nomenclature', 'Protonym', 'OTU (Biology)'],
      nomenclature: '',
      filterSelected: [],
      hideInfo: [{
        label: 'Topics',
        key: '.history__citation_topics',
        value: true
      },
      {
        label: 'Notes',
        key: '.annotation__note',
        value: true
      },
      {
        label: 'Soft validation',
        key: '.soft_validation_anchor',
        value: true
      }],
      filter: [
        {
          label: 'History',
          key: 'history-is-first',
          value: true
        },
        {
          label: 'Protonym',
          key: 'history-origin',
          value: 'protonym'
        },
        {
          label: 'Valid',
          key: 'history-valid-name',
          value: true
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
    hideInfo: {
      handler (newVal) {
        this.hideInfo.forEach(item => {
          document.querySelectorAll(item.key).forEach(element => {
            item.value ? element.classList.remove('hidden') : element.classList.add('hidden')
          })
        })
      },
      deep: true
    }
  },
  methods: {
    checkFilter (item) {
      return (this.filterSelected.every(filter => {
        return item.data_attributes[filter.key] == filter.value
      }) && (this.current ? item.data_attributes['history-object-id'] === this.nomenclature.reference_object_valid_taxon_name : true))
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