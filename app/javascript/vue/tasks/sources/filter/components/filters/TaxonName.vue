<template>
  <div>
    <h3>Nomenclatural scope</h3>
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
        <label>
          <input
            type="checkbox"
            name="taxon-validity"
            v-model="nomenclature.citations_on_otus">
          Citations on OTUs
        </label>
      </div>
    </div>
  </div>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { TaxonName } from 'routes/endpoints'

export default {
  components: { Autocomplete },

  props: {
    modelValue: {
      type: Object,
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  data () {
    return {
      taxon: undefined
    }
  },

  computed: {
    nomenclature: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  mounted () {
    const urlParams = URLParamsToJSON(location.href)
    if (Object.keys(urlParams).length) {
      if (urlParams.ancestor_id) {
        this.setTaxon(urlParams.ancestor_id)
      }
      this.nomenclature.citations_on_otus = urlParams?.citations_on_otus
    }
  },

  methods: {
    setTaxon (id) {
      TaxonName.find(id).then(response => {
        this.taxon = response.body
        this.nomenclature.ancestor_id = response.body.id
      })
    },

    removeTaxon () {
      this.taxon = undefined
      this.determination.ancestor_id = undefined
    }
  }
}
</script>
