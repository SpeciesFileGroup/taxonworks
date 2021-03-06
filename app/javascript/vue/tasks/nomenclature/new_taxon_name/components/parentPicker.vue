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
        <li v-for="code in getCodes">
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
import Autocomplete from 'components/autocomplete.vue'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import AjaxCall from 'helpers/ajaxCall'

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
    },
    getInitLoad() {
      return this.$store.getters[GetterNames.GetInitLoad]
    }
  },
  data: function () {
    return {
      code: undefined,
      validParent: undefined
    }
  },
  watch: {
    getInitLoad(newVal) {
      if(newVal)
        this.loadWithParentID()
    },
    parent(newVal) {
      if(newVal && newVal.id != newVal.cached_valid_taxon_name_id) {
        AjaxCall('get', `/taxon_names/${newVal.cached_valid_taxon_name_id}.json`).then(response => {
          this.validParent = response.body
        })
      }
    }
  },
  methods: {
    loadWithParentID() {
      var url = new URL(window.location.href);
      var parentId = url.searchParams.get("parent_id");
      if(parentId != null && Number.isInteger(Number(parentId)))
        this.parentSelected(parentId)
    },
    setParentRank: function (parent) {
      this.$store.dispatch(ActionNames.SetParentAndRanks, parent)
      this.$store.commit(MutationNames.UpdateLastChange)
    },
    parentSelected(id, saveToo = false) {
      this.$store.commit(MutationNames.SetParentId, id)
      AjaxCall('get', `/taxon_names/${id}.json`).then(response => {
        if (response.body.parent_id != null) {
          this.$store.commit(MutationNames.SetNomenclaturalCode, response.body.nomenclatural_code)
          this.setParentRank(response.body)
          if(saveToo) {
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
