<template>
  <div>
    <div class="horizontal-left-content">
      <autocomplete
        input-id="parent-name"
        url="/taxon_names/autocomplete"
        label="label_html"
        min="2"
        @getItem="parentSelected($event.id)"
        display="label"
        :add-params="{
          'type[]': 'Protonym',
          valid: true
        }"
        :send-label="parent.object_label"
        param="term"/>
      <default-taxon
        class="margin-small-left"
        section="TaxonNames"
        @getId="parentSelected"
        type="TaxonName"/>
      <div
        v-if="parent && parent.id != parent.cached_valid_taxon_name_id"
        class="horizontal-left-content separate-left">
        <span
          data-icon="warning"
          title="This parent is invalid"/>
        <button
          v-if="validParent"
          type="button"
          class="button normal-input button-submit"
          @click="parentSelected(parent.cached_valid_taxon_name_id, true)">
          Set to {{ validParent.name }}
        </button>
      </div>
    </div>
    <div
      class="field"
      v-if="!taxon.id && parent && parent.parent_id == null">
      <h4>Nomenclature code</h4>
      <ul class="no_bullets">
        <li
          v-for="code in getCodes"
          :key="code">
          <label class="middle uppercase">
            <input
              type="radio"
              name="nomenclatureCode"
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
import Autocomplete from 'components/ui/Autocomplete.vue'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import { TaxonName } from 'routes/endpoints'

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
        const parent = this.$store.getters[GetterNames.GetParent]
        return parent || ''
      }
    },

    getCodes: {
      get () {
        const codes = Object.keys(this.$store.getters[GetterNames.GetRankList])
        return codes || ''
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
    },

    getInitLoad() {
      return this.$store.getters[GetterNames.GetInitLoad]
    }
  },

  data () {
    return {
      validParent: undefined
    }
  },

  watch: {
    getInitLoad (newVal) {
      if(newVal)
        this.loadWithParentID()
    },

    parent (newVal) {
      if (newVal && newVal.id !== newVal.cached_valid_taxon_name_id) {
        TaxonName.find(newVal.cached_valid_taxon_name_id).then(response => {
          this.validParent = response.body
        })
      }
    }
  },

  methods: {
    loadWithParentID() {
      const url = new URL(window.location.href);
      const parentId = url.searchParams.get('parent_id')

      if(parentId != null && Number.isInteger(Number(parentId)))
        this.parentSelected(parentId)
    },

    setParentRank (parent) {
      this.$store.dispatch(ActionNames.SetParentAndRanks, parent)
      this.$store.commit(MutationNames.UpdateLastChange)
    },

    parentSelected (id, saveToo = false) {
      this.$store.commit(MutationNames.SetParentId, id)
      TaxonName.find(id).then(response => {
        if (response.body.parent_id != null) {
          this.$store.commit(MutationNames.SetNomenclaturalCode, response.body.nomenclatural_code)
          this.setParentRank(response.body)
          if (saveToo) {
            this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon)
          }
        } else {
          this.$store.commit(MutationNames.SetParent, response.body)
        }
      })
    }
  }
}
</script>
