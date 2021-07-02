<template>
  <div class="panel basic-information separate-top">
    <div class="header">
      <h3>Rows</h3>
    </div>
    <div class="body">
      <div>
        <spinner-component v-if="loadingTag"/> 
        <fieldset class="separate-bottom">
          <legend>Tag/Keyword</legend>
          <smart-selector
            :options="smartOptions"
            v-model="view"
            name="rows-smart"/>
          <component 
            v-if="componentExist"
            @send="create"
            :list="selectorLists[view]"
            :is="view + 'Component'"/>
          <autocomplete
            v-else
            url="/controlled_vocabulary_terms/autocomplete"
            param="term"
            label="label_html"
            :clear-after="true"
            placeholder="Search a keyword"
            @getItem="create"
            min="2"
            />
        </fieldset>
      </div>
      <div>
        <spinner-component v-if="loadingTaxon"/> 
        <fieldset>
          <legend>Taxon name</legend>
          <smart-selector
            :options="smartTaxon"
            v-model="viewTaxonName"
            name="rows-smart-taxon"/>
          <template v-if="smartTaxon.length">
            <smart-taxon-list
              class="no_bullets"
              v-if="viewTaxonName !== 'search'"
              :created-list="rowsListDynamic"
              :list="listTaxon[viewTaxonName]"
              @selected="createTaxon"
              value-compare="taxon_name_id"/>
            <autocomplete
              v-else
              url="/taxon_names/autocomplete"
              param="term"
              label="label_html"
              :clear-after="true"
              placeholder="Search a taxon name"
              @getItem="createTaxon"
              min="2"/>
          </template>
        </fieldset>
      </div>
    </div>
  </div>
</template>
<script>

import smartSelector from '../shared/smartSelector'
import {
  default as quickComponent,
  default as recentComponent,
  default as pinboardComponent
} from '../shared/tag_list'

import smartTaxonList from './dynamic/smartList'
import Autocomplete from 'components/ui/Autocomplete'
import SpinnerComponent from 'components/spinner'
import { GetSmartSelector } from '../../request/resources'
import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import ObservationTypes from '../../const/types.js'

export default {
  components: {
    smartSelector,
    quickComponent,
    recentComponent,
    pinboardComponent,
    smartTaxonList,
    Autocomplete,
    SpinnerComponent
  },

  computed: {
    componentExist() {
      return this.$options.components[this.view + 'Component']
    },
    matrixId() {
      return this.$store.getters[GetterNames.GetMatrix].id
    },
    rowsListDynamic() {
      return this.$store.getters[GetterNames.GetMatrixRowsDynamic]
    }
  },

  data () {
    return {
      smartOptions: ['quick', 'recent', 'pinboard', 'tag'],
      smartTaxon: [],
      selectorLists: undefined,
      listTaxon: undefined,
      view: undefined,
      viewTaxonName: 'search',
      loadingTag: true,
      loadingTaxon: true
    }
  },
  mounted() {
    GetSmartSelector('keywords').then(response => {
      this.smartOptions = this.smartOptions.filter(value => Object.keys(response.body).includes(value))
      this.selectorLists = response.body
      this.loadingTag = false
      this.smartOptions.push('search')
    })
    GetSmartSelector('taxon_names').then(response => {
      this.smartTaxon = ['quick', 'recent', 'pinboard'].filter(value => Object.keys(response.body).includes(value))
      this.smartTaxon.push('search')
      this.listTaxon = response.body
      this.loadingTaxon = false
    })
  },
  methods: {
    create (item) {
      let data = {
        controlled_vocabulary_term_id: item.id,
        observation_matrix_id: this.matrixId,
        type: ObservationTypes.Row.Tag
      }
      this.$store.dispatch(ActionNames.CreateRowItem, data)
    },
    createTaxon (item) {
      let data = {
        taxon_name_id: item.id,
        observation_matrix_id: this.matrixId,
        type: ObservationTypes.Row.TaxonName
      }
      this.$store.dispatch(ActionNames.CreateRowItem, data)
    }
  }
}
</script>
