<template>
  <div id="typeBox">
    <div class="panel separate-bottom">
      <div class="content header">
        <h3
          v-if="taxon.id"
          class="flex-separate middle"
        >
          <a
            :href="`/tasks/nomenclature/browse?taxon_name_id=${taxon.id}`"
            class="taxonname"
            v-hotkey="shortcuts">
            <span v-html="taxonNameAndAuthor" />
          </a>
          <div>
            <div class="horizontal-right-content margin-small-bottom">
              <otu-radial
                ref="browseOtu"
                :object-id="taxon.id"
                :taxon-name="taxon.object_tag"/>
              <radial-annotator :global-id="taxon.global_id"/>
              <radial-object :global-id="taxon.global_id"/>
            </div>
            <div class="horizontal-right-content">
              <pin-component
                class="circle-button"
                type="TaxonName"
                :object-id="taxon.id"/>
              <a
                class="circle-button btn-edit button-default"
                :href="`/tasks/nomenclature/new_taxon_name?taxon_name_id=${taxon.id}`"/>
            </div>
          </div>
        </h3>
        <span
          v-if="typeMaterial.id"
          v-html="typeMaterial.object_tag"/>
      </div>
    </div>
    <div
      class="panel content"
      v-if="typesMaterial.length">
      <button
        type="button"
        @click="newType"
        class="button normal-input button-default">New type</button>

      <table class="margin-medium-top full_width">
        <thead>
          <tr>
            <th>Type</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="item in typesMaterial"
            :key="item.id"
            :class="{ highlight: typeMaterial.id === item.id }">
            <td>
              {{ item.type_type }} ({{ item.collection_object.total }})
            </td>
            <td>
              <div class="horizontal-right-content">
                <radial-annotator :global-id="item.global_id"/>
                <span 
                  @click="setTypeMaterial(item)"
                  class="button circle-button btn-edit button-default"/>
                <span
                  @click="removeTypeSpecimen(item)"
                  class="button circle-button btn-delete"/>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
<script>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialObject from 'components/radials/navigation/radial.vue'
import { GetterNames } from '../store/getters/getters'
import ActionNames from '../store/actions/actionNames'
import PinComponent from 'components/ui/Pinboard/VPin.vue'
import OtuRadial from 'components/otu/otu.vue'
import platformKey from 'helpers/getMacKey'
import { RouteNames } from 'routes/routes'

export default {
  components: {
    RadialAnnotator,
    RadialObject,
    OtuRadial,
    PinComponent
  },

  computed: {
    typeMaterial () {
      return this.$store.getters[GetterNames.GetTypeMaterial]
    },

    typesMaterial () {
      return this.$store.getters[GetterNames.GetTypeMaterials]
    },

    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },

    taxonNameAndAuthor () {
      return `${this.taxon.cached_html} ${this.taxon.cached_author_year || ''}`
    },

    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+o`] = this.switchBrowseOtu
      keys[`${platformKey()}+e`] = this.switchComprehensive
      keys[`${platformKey()}+t`] = this.switchNewTaxonName

      return keys
    }
  },

  methods: {
    reloadPage () {
      window.location.href = '/tasks/type_material/edit_type_material'
    },

    removeTypeSpecimen (item) {
      if (window.confirm('Are you sure you want to destroy this record?')) {
        this.$store.dispatch(ActionNames.RemoveTypeSpecimen, item.id)
      }
    },

    setTypeMaterial (material) {
      this.$store.dispatch(ActionNames.LoadTypeMaterial, material)
    },

    newType () {
      this.$store.dispatch(ActionNames.SetNewTypeMaterial)
    },

    switchComprehensive () {
      const coId = this.typeMaterial.collection_object_id
      const coParam = coId
        ? `&collection_object_id=${coId}`
        : ''

      window.open(`${RouteNames.DigitizeTask}?taxon_name_id=${this.taxon.id}${coParam}`, '_self')
    },

    switchBrowseOtu () {
      this.$refs.browseOtu.openApp()
    },

    switchNewTaxonName () {
      window.open(`${RouteNames.NewTaxonName}?taxon_name_id=${this.taxon.id}`, '_self')
    }
  }
}
</script>
<style lang="scss" scoped>
  .taxon-options {
    display: flex;
    justify-content: space-between;
  }

  .taxonname {
    font-size: 14px;
  }
</style>
