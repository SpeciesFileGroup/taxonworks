<template>
  <div class="panel type-specimen-box">
    <div class="header flex-separate middle">
      <h3>Taxon name</h3>
      <expand v-model="displayBody"/>
    </div>
    <div
      class="body"
      v-if="displayBody">
      <div class="field">
        <label>Species name</label>
        <autocomplete
          class="types_field"
          url="/taxon_names/autocomplete"
          param="term"
          label="label_html"
          display="label"
          @getItem="setTypeSpecimen($event.id)"
          min="2"
          :add-params="{
            'type[]': 'Protonym',
            'nomenclature_group[]': 'SpeciesGroup'
        }"/>
      </div>
      <display-list
        :list="typesMaterial"
        :annotator="true"
        @delete="removeTypeSpecimen"
        label="object_tag"/>
    </div>
  </div>
</template>

<script>

import Expand from './expand.vue'
import Autocomplete from 'components/ui/Autocomplete.vue'
import DisplayList from 'components/displayList.vue'

import { GetterNames } from '../store/getters/getters'
import ActionNames from '../store/actions/actionNames'

export default {
  components: {
    DisplayList,
    Autocomplete,
    Expand
  },
  computed: {
    typesMaterial () {
      return this.$store.getters[GetterNames.GetTypeMaterials]
    }
  },
  data: function () {
    return {
      displayBody: true
    }
  },
  methods: {
    setTypeSpecimen (id) {
      this.$store.dispatch(ActionNames.LoadTaxonName, id).then(() => {
        this.$store.dispatch(ActionNames.LoadTypeMaterials, id)
      })
    },
    removeTypeSpecimen (item) {
      this.$store.dispatch(ActionNames.RemoveTypeSpecimen, item.id)
    }
  }
}
</script>
