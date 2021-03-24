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
    <div class="field">
      <fieldset>
        <legend>Determiner</legend>
        <smart-selector
          :autocomplete-params="{'roles[]' : 'Determiner'}"
          model="people"
          klass="CollectionObject"
          pin-section="People"
          pin-type="People"
          @selected="addDeterminer"/>
      </fieldset>
    </div>
    <table
      v-if="determiners.length"
      class="vue-table">
      <thead>
        <tr>
          <th>Name</th>
          <th></th>
          <th></th>
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody">
        <template
          v-for="(item, index) in determiners"
          class="table-entrys-list">
          <row-item
            class="list-complete-item"
            :key="index"
            :item="item"
            label="object_tag"
            :options="{
              AND: true,
              OR: false
            }"
            v-model="item.and"
            @remove="removePerson(index)"
          />
        </template>
      </transition-group>
    </table>
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
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { GetTaxonName, GetOtu, GetPerson } from '../../request/resources'
import RowItem from 'tasks/sources/filter/components/filters/shared/RowItem'
import SmartSelector from 'components/smartSelector'

export default {
  components: {
    Autocomplete,
    RowItem,
    SmartSelector
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

        if (!newVal.determiner_id.length && !newVal.determiner_id_or.length && this.determiners.length) {
          this.determiners = []
        }
      },
      deep: true
    },

    determiners: {
      handler () {
        this.determination.determiner_id = this.determiners.filter(determiner => determiner.and).map(determiner => determiner.id)
        this.determination.determiner_id_or = this.determiners.filter(determiner => !determiner.and).map(determiner => determiner.id)
      },
      deep: true
    }
  },

  created () {
    const { 
      ancestor_id,
      validity,
      current_determinations,
      determiner_id_or = [],
      determiner_id = [],
      otu_ids = [],
    } = URLParamsToJSON(location.href)
    if (ancestor_id) {
      this.setTaxon(ancestor_id)
    }

    otu_ids.forEach(id => { this.addOtu(id) })

    determiner_id_or.forEach(id => {
      GetPerson(id).then(({ body }) => {
        this.addDeterminer(body, false)
      })
    })
    determiner_id.forEach(id => {
      GetPerson(id).then(({ body }) => {
        this.addDeterminer(body, true)
      })
    })
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
    addDeterminer (determiner, and = true) {
      if (!this.determiners.find(item => item.id === determiner.id)) {
        this.determiners.push({ ...determiner, and })
      }
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
