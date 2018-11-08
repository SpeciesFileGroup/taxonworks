<template>
  <div>
    <div class="horizontal-left-content">
      <autocomplete
        url="/taxon_names/autocomplete"
        label="label_html"
        min="2"
        event-send="parentSelected"
        display="label"
        :add-params="{
          'type[]': 'Protonym',
          valid: true
        }"
        :send-label="parent.name"
        param="term"/>
      <default-taxon
        section="TaxonNames"
        @getId="parentSelected"
        type="TaxonName"/>
    </div>
    <div
      class="field"
      v-if="!taxon.id && parent && parent.parent_id == null">
      <h4>Nomenclature code</h4>
      <ul class="no_bullets">
        <li v-for="code in getCodes">
          <label class="middle uppercase">
            <input
              type="radio"
              name="rankSelected"
              v-model="nomenclatureCode"
              :value="code">
            {{ code }}
          </label>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import DefaultTaxon from 'components/getDefaultPin.vue'
import Autocomplete from '../../../components/autocomplete.vue'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'

export default {
  components: {
    Autocomplete,
    DefaultTaxon
  },
  computed: {
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    parent: {
      get () {
        let value = this.$store.getters[GetterNames.GetParent]
        return (value != undefined ? value : '')
      }
    },
    getCodes: {
      get () {
        let codes = Object.keys(this.$store.getters[GetterNames.GetRankList])
        return (codes != undefined ? codes : '')
      }
    },
    nomenclatureCode: {
      get () {
        return this.$store.getters[GetterNames.GetNomenclatureCode]
      },
      set (value) {
        this.$store.commit(MutationNames.SetNomenclaturalCode, value)
        this.setParentRank(this.parent)
      }
    }
  },
  data: function () {
    return {
      code: undefined
    }
  },
  mounted: function () {
    this.$on('parentSelected', function (item) {
      this.parentSelected(item.id)
    })
  },
  methods: {
    setParentRank: function (parent) {
      this.$store.commit(MutationNames.SetRankClass, undefined)
      this.$store.dispatch(ActionNames.SetParentAndRanks, parent)
      this.$store.commit(MutationNames.UpdateLastChange)
    },
    parentSelected(id) {
      this.$store.commit(MutationNames.SetParentId, id)
      this.$http.get(`/taxon_names/${id}`).then(response => {
        if (response.body.parent_id != null) {
          this.$store.commit(MutationNames.SetNomenclaturalCode, response.body.nomenclatural_code)
          this.setParentRank(response.body)
        } else {
          this.$store.commit(MutationNames.SetParent, response.body)
        }
      })
    }
  }
}
</script>
