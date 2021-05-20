<template>
  <div>
    <h2>Taxon name</h2>
    <div class="field">
      <button
        v-if="taxon && taxon.parent && checkRank(taxon.parent)"
        type="button"
        class="button normal-input button-default"
        @click="getTaxon(taxon.parent)">
        Set to {{ taxon.parent.name }}
      </button>
    </div>
    <div class="field">
      <autocomplete
        class="fill_width"
        url="/taxon_names/autocomplete"
        param="term"
        display="label"
        label="label_html"
        :clear-after="true"
        placeholder="Search a taxon name"
        :add-params="{
          'type[]': 'Protonym'
        }"
        @getItem="getTaxon"/>
    </div>
    <span 
      v-if="taxon"
      v-html="taxon.object_tag"/>
  </div>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete'
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'
import { RouteNames } from 'routes/routes'
import { TaxonName } from 'routes/endpoints'

export default {
  components: {
    Autocomplete
  },
  computed: {
    taxon: {
      get () {
        return this.$store.getters[GetterNames.GetTaxon]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxon, value)
      }
    },
    ranksList () {
      return this.$store.getters[GetterNames.GetRanks]
    }
  },
  mounted () {
    this.GetParams()
  },
  methods: {
    GetParams () {
      const urlParams = new URLSearchParams(window.location.search)
      const taxonId = urlParams.get('taxon_name_id')

      if ((/^\d+$/).test(taxonId)) {
        this.getTaxon({ id: taxonId })
      }
    },
    checkRank (taxon) {
      const ranksFilter = [...new Set(this.getRankNames(this.ranksList))]
      return ranksFilter.find(rank => taxon.rank === rank)
    },
    getTaxon (event) {
      TaxonName.find(event.id).then(response => {
        if (this.checkRank(response.body)) {
          this.taxon = response.body
          history.pushState(null, null, `${RouteNames.NomenclatureStats}?taxon_name_id=${this.taxon.id}`)
        } else {
          TW.workbench.alert.create('Please choose a taxon with a governed code of nomenclature.', 'alert')
        }
      })
    },
    getRankNames (list, nameList = []) {
      for (const key in list) {
        if (typeof list[key] === 'object') {
          this.getRankNames(list[key], nameList)
        } else {
          if (key === 'name') {
            nameList.push(list[key])
          }
        }
      }
      return nameList
    }
  }
}
</script>

<style lang="scss" scoped>
  .field {
    label {
      display: block;
    }
  }
  .field-year {
    width: 60px;
  }
  ::v-deep .vue-autocomplete-list {
    min-width: 800px;
  }
</style>
