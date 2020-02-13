<template>
  <div>
    <h2>Determinations</h2>
    <h3>Taxon name</h3>
    <div>
      <autocomplete
        url="/taxon_names/autocomplete"
        param="term"
        label="label_html"
        :clear-after="true"
        placeholder="Search a taxon name"
        @getItem="setTaxon"
      />
      <div 
        v-if="taxon"
        class="field middle">
        <span
          v-html="taxon.label_html"/>
        <span
          class="separate-left button button-circle btn-undo button-default"
          @click="removeTaxon"/>
      </div>
      <div class="field separate-top">
        <ul class="no_bullets">
          <li 
            v-for="item in validityOptions"
            :key="item.value">
            <label>
              <input 
                type="radio"
                :value="item.value"
                name="taxon-validity"
                v-model="determination.validity">
              {{ item.label }}
            </label>
          </li>
        </ul>
      </div>      
    </div>
    <h3>Otu</h3>
    <autocomplete
      url="/otus/autocomplete"
      placeholder="Select an otu"
      param="term"
      label="label_html"
      :clear-after="true"
      display="label"
      @getItem="addOtu" />
    <div class="field separate-top">
      <ul class="no_bullets">
        <li 
          v-for="item in currentDeterminationsOptions"
          :key="item.value">
          <label>
            <input 
              type="radio"
              :value="item.value"
              name="current-determination"
              v-model="determination.current_determinations">
            {{ item.label }}
          </label>
        </li>
      </ul>
    </div>
    <div class="field separate-top">
      <ul class="no_bullets table-entrys-list">
        <li
          class="middle flex-separate list-complete-item"
          v-for="(otu, index) in otusStore"
          :key="otu.id">
          <span v-html="otu.label_html"/>
          <span
            class="btn-delete button-circle"
            @click="removeOtu(index)"/>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'

export default {
  components: {
    Autocomplete
  },
  props: {
    value: {
      type: Object,
      default: undefined
    }
  },
  computed: {
    determination: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      otusStore: [],
      taxon: undefined,
      currentDeterminationsOptions: [
        {
          label: 'Current and historical',
          value: undefined,
        },
        {
          label: 'Current only',
          value: true
        },
        {
          label: 'Historical only',
          value: false
        }
      ],
      validityOptions: [
        {
          label: 'Both valid/invalid',
          value: undefined
        },
        {
          label: 'Valid only',
          value: true
        },
        {
          label: 'Invalid only',
          value: false
        }
      ]
    }
  },
  watch: {
    determination: {
      handler (newVal) {
        if (!newVal.otu_ids.length) {
          this.otusStore = []
        }
        if(!newVal.ancestor_id) {
          this.taxon = undefined
        }
      },
      deep: true
    }
  },
  methods: {
    removeOtu (index) {
      this.determination.otu_ids.splice(index, 1)
      this.otusStore.splice(index, 1)
    },
    addOtu (item) {
      this.determination.otu_ids.push(item.id)
      this.otusStore.push(item)
    },
    setTaxon(taxon) {
      this.taxon = taxon
      this.determination.ancestor_id = taxon.id
    },
    removeTaxon() {
      this.taxon = undefined
      this.determination.ancestor_id = undefined
    }
  }
}
</script>
<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>
