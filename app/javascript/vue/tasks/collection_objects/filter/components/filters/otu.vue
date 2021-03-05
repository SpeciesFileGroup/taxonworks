<template>
  <div>
    <h3>Determinations</h3>
    <label>Taxon name</label>
    <div class="field">
      <autocomplete
        url="/taxon_names/autocomplete"
        param="term"
        label="label_html"
        clear-after
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
    <div class="field">
      <label>Otu</label>
      <autocomplete
        url="/otus/autocomplete"
        placeholder="Select an otu"
        param="term"
        label="label_html"
        clear-after
        display="label"
        @getItem="addOtu($event.id)" />
    </div>
    <div class="field">
      <label>Determiner</label>
      <autocomplete
        url="/people/autocomplete"
        placeholder="Select a determiner"
        param="term"
        clear-after
        label="label_html"
        :add-params="{
          'roles[]': 'Determiner'
        }"
        @getItem="addDeterminer($event.id)"/>
      <display-list
        soft-delete
        :list="determiners"
        :delete-warning="false"
        @deleteIndex="removePerson"
        label="cached"/>
    </div>
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
import { GetTaxonName, GetOtu, GetPerson } from '../../request/resources'
import DisplayList from 'components/displayList'

export default {
  components: {
    Autocomplete,
    DisplayList
  },

  props: {
    value: {
      type: Object,
      default: undefined
    }
  },

  data () {
    return {
      otusStore: [],
      determiners: [],
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

  watch: {
    determination: {
      handler (newVal) {
        if (!newVal.otu_ids.length) {
          this.otusStore = []
        }
        if (!newVal.ancestor_id) {
          this.taxon = undefined
        }
        if (!newVal.determiner_id.length) {
          this.determiners = []
        }
      },
      deep: true
    }
  },

  created () {
    const { ancestor_id, otu_ids, validity, current_determinations, determiner_id } = URLParamsToJSON(location.href)
    if (ancestor_id) {
      this.setTaxon(ancestor_id)
    }
    if (otu_ids) {
      otu_ids.forEach(id => { this.addOtu(id) })
    }
    if (determiner_id) {
      determiner_id.forEach(id => { this.addDeterminer(id) })
    }
    this.determination.validity = validity
    this.determination.current_determinations = current_determinations
  },

  methods: {
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
    addDeterminer (id) {
      GetPerson(id).then(({ body }) => {
        this.determiners.push(body)
        this.determination.determiner_id.push(body.id)
      })
    },
    removeTaxon () {
      this.taxon = undefined
      this.determination.ancestor_id = undefined
    },
    removePerson (index) {
      this.determiners.splice(index, 1)
      this.determination.determiner_id.splice(index, 1)
    },
    removeOtu (index) {
      this.determination.otu_ids.splice(index, 1)
      this.otusStore.splice(index, 1)
    }
  }
}
</script>
<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>
