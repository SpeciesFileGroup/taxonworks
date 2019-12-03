<template>
  <section-panel title="Timeline">
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
    <div>
      <h3>Citations</h3>
      <ul class="taxonomic_history">
        <li 
          v-for="item in nomenclature.items"
          v-if="checkFilter(item)">
          <span v-html="item.label_html"/>
        </li>
      </ul>
      <h3>References</h3>
      <ul class="taxonomic_history">
        <template v-for="source in nomenclature.sources">
        <li 
          v-for="item in source"
          v-if="filterSource(source)">
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

export default {
  components: {
    SectionPanel
  },
  props: {
    otu: {
      type: Object
    }
  },
  data() {
    return {
      nomenclature: '',
      filterSelected: [],
      filter: [
        {
          label: 'History',
          key: 'history-is-subsequent',
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
