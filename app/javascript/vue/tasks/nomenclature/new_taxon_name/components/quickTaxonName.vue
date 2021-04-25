<template>
  <div class="horizontal-left-content">
    <autocomplete
      slot="body"
      url="/taxon_names/autocomplete"
      label="label_html"
      display="label"
      min="3"
      event-send="autocompleteType"
      @getItem="$emit('getItem', $event)"
      @found="nothing = !$event"
      @getInput="name = $event"
      placeholder="Search taxon name for the new relationship..."
      :add-params="{ type: 'Protonym', 'nomenclature_group[]': group }"
      param="term"/>
    <button
      v-if="nothing"
      type="button"
      @click="showModal = true"
      class="button normal-input button-default margin-small-left">
      New
    </button>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Create new species taxon name</h3>
      <div slot="body">
        <label>Name</label>
        <input
          type="text"
          v-model="name"
          class="full_width">
        <p>Are you sure you want to proceed? Type "{{ checkWord }}" to proceed.</p>
        <input
          type="text"
          class="full_width"
          v-model="confirmInput"
          @keypress.enter.prevent="create()"
          ref="inputtext"
          :placeholder="`Write ${checkWord} to continue`">
      </div>
      <div slot="footer">
        <button 
          type="button"
          class="button normal-input button-submit"
          :disabled="!checkInput"
          @click="create()">
          Create
        </button>
      </div>
    </modal-component>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'
import ModalComponent from 'components/modal'
import { GetterNames } from '../store/getters/getters'
import { createTaxonName } from '../request/resources'
import { TaxonNames } from 'routes/endpoints/TaxonNames.js'

export default {
  components: {
    Autocomplete,
    ModalComponent
  },
  props: {
    group: {
      type: String,
      required: true
    }
  },
  computed: {
    nomenclatureCode () {
      return this.$store.getters[GetterNames.GetNomenclaturalCode]
    },
    ranks () {
      return this.$store.getters[GetterNames.GetRankList][this.nomenclatureCode]
    },
    speciesRank () {
      return this.ranksList.find(rank => { return rank.endsWith('::Species') })
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    checkInput() {
      return this.name.length > 1 && this.checkWord === this.confirmInput.toUpperCase()
    }
  },
  data () {
    return {
      nothing: false,
      ranksList: [],
      confirmInput: '',
      name: '',
      checkWord: 'CREATE',
      showModal: false
    }
  },
  mounted () {
    this.ranksList = [].concat(...this.flatRankList(this.ranks))
  },
  methods: {
    flatRankList(rank) {
      if(Array.isArray(rank)) {
        return rank.map(item => {
          return item.rank_class
        })
      }
      else {
        let keys = Object.keys(rank)
        return keys.map(key => {
          return this.flatRankList(rank[key])
        })
      }
    },
    create () {
      TaxonNames.create({
        taxon_name: {
          name: this.name,
          rank_class: this.speciesRank,
          parent_id: this.taxon.id,
          type: 'Protonym'
        }
      }).then(response => {
        this.$emit('getItem', response.body)
      })
    }
  }
}
</script>

<style>

</style>