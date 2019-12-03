<template>
  <section-panel title="Nomenclature">
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
    </div>
    <div>
      <ul class="taxonomic_history">
        <li 
          v-for="item in nomenclature.items"
          v-if="checkFilter(item)">
          <span v-html="item.label_html"/>
        </li>
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
      ]
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
      return this.filterSelected.every(filter => {
        return item.data_attributes[filter.key] == filter.value
      })
    }
  }
}
</script>
