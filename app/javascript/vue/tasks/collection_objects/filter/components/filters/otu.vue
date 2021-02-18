<template>
  <div>
    <h3>Determinations</h3>
    <h3>Taxon name</h3>
    <div>
      <autocomplete
        url="/taxon_names/autocomplete"
        param="term"
        label="label_html"
        :clear-after="true"
        placeholder="Search a taxon name"
        @getItem="setTaxon($event.id)"
      />
      <p
        v-if="taxon"
        class="field middle">
        <span
          class="margin-small-right"
          v-html="taxon.object_tag"/>
        <span
          class="separate-left button button-circle btn-undo button-default"
          @click="removeTaxon"/>
      </p>
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
      @getItem="addOtu($event.id)" />
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
          <span v-html="otu.object_tag"/>
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
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { GetTaxonName, GetOtu } from '../../request/resources'

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
          value: undefined
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
  mounted () {
    const urlParams = URLParamsToJSON(location.href)
    if (Object.keys(urlParams).length) {
      if (urlParams.ancestor_id) {
        this.setTaxon(urlParams.ancestor_id)
      }
      if (urlParams.otu_ids) {
        urlParams.otu_ids.forEach(id => { this.addOtu(id) })
      }
      this.determination.validity = urlParams.validity
      this.determination.current_determinations = urlParams.current_determinations
    }
  },
  methods: {
    removeOtu (index) {
      this.determination.otu_ids.splice(index, 1)
      this.otusStore.splice(index, 1)
    },
    addOtu (id) {
      GetOtu(id).then(response => {
        this.determination.otu_ids.push(response.body.id)
        this.otusStore.push(response.body)
      })
    },
    setTaxon (id) {
      GetTaxonName(id).then(response => {
        this.taxon = response.body
        this.determination.ancestor_id = response.body.id
      })
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
