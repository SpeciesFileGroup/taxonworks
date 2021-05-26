<template>
  <block-layout :warning="!(typeMaterial.id || typeMaterials.length)">
    <div slot="header">
      <h3>Type material</h3>
      <span
        v-shortkey="[getOSKey(), 'm']"
        @shortkey="switchTypeMaterial"/>
      <span
        v-shortkey="[getOSKey(), 't']"
        @shortkey="switchNewTaxonName"/>
      <span
        v-shortkey="[getOSKey(), 'o']"
        @shortkey="switchBrowseOtu"/>
      <span
        v-shortkey="[getOSKey(), 'b']"
        @shortkey="switchBrowseNomenclature"/>
    </div>
    <div slot="body">
      <ul
        class="no_bullets"
        v-if="typeMaterials.length">
        <li
          v-for="item in typeMaterials"
          :key="item.id"
          class="horizontal-left-content">
          <a
            :href="`/tasks/nomenclature/new_taxon_name?taxon_name_id=${item.protonym_id}`"
            v-html="item.object_tag" />
          <radial-annotator
            :global-id="item.global_id"
            type="annotations"/>
          <span
            class="button circle-button btn-delete"
            @click="destroyTypeMateria(item)"/>
        </li>
      </ul>
      <div v-show="!typeMaterials.length">
        <div class="separate-bottom">
          <fieldset>
            <legend>Taxon name</legend>
            <smart-selector
              ref="smartSelector"
              model="taxon_names"
              klass="TypeMaterial"
              :params="{ 'nomenclature_group[]': 'SpeciesGroup' }"
              :autocomplete-params="{ 'nomenclature_group[]': 'SpeciesGroup' }"
              pin-section="TaxonNames"
              pin-type="TaxonName"
              @selected="selectTaxon($event.id)"
            />
            <div
              v-if="taxon"
              class="horizontal-left-content">
              <a
                :href="`/tasks/nomenclature/new_taxon_name?taxon_name_id=${taxon.id}`"
                v-html="taxon.object_tag" />
              <span
                class="button circle-button btn-undo button-default"
                @click="taxon = undefined"/>
            </div>
          </fieldset>
        </div>
        <div class="separate-bottom">
          <p>Type type</p>
          <ul
            class="no_bullets"
            v-if="checkForTypeList">
            <li v-for="(item, key) in types[taxon.nomenclatural_code]">
              <label>
                <input
                  class="capitalize"
                  type="radio"
                  v-model="type"
                  :value="key">
                {{ key }}
              </label>
            </li>
          </ul>
          <span v-else>Select a taxon name first</span>
        </div>
        <fieldset>
          <legend>Source</legend>
          <smart-selector
            ref="sourceSmartSelector"
            model="sources"
            pin-section="Sources"
            pin-type="Source"
            @selected="selectSource"
          />
          <div
            v-if="sourceSelected"
            class="horizontal-left-content margin-medium-top">
            <span v-html="sourceSelected.object_tag"/>
            <span
              class="button circle-button btn-undo button-default"
              @click="newCitation(); sourceSelected = undefined"/>
          </div>
          <input
            class="margin-small-top"
            type="text"
            v-model="origin_citation_attributes.pages"
            placeholder="Pages">
        </fieldset>
      </div>
    </div>
  </block-layout>
</template>

<script>

import { TypeMaterial } from 'routes/endpoints'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations'
import ActionNames from '../../store/actions/actionNames.js'
import BlockLayout from 'components/layout/BlockLayout.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'
import GetOSKey from 'helpers/getMacKey'

export default {
  components: {
    BlockLayout,
    SmartSelector,
    RadialAnnotator
  },
  computed: {
    taxonIdFormOtu () {
      const tmpOtu = this.$store.getters[GetterNames.GetTmpData].otu
      return (tmpOtu && tmpOtu.hasOwnProperty('taxon_name_id')) ? tmpOtu.taxon_name_id : undefined
    },
    checkForTypeList () {
      return this.types && this.taxon
    },
    typeMaterial () {
      return this.$store.getters[GetterNames.GetTypeMaterial]
    },
    typeMaterials () {
      return this.$store.getters[GetterNames.GetTypeMaterials]
    },
    taxon: {
      get () {
        return this.$store.getters[GetterNames.GetTypeMaterial].taxon
      },
      set (value) {
        this.$store.commit(MutationNames.SetTypeMaterialTaxon, value)
      }
    },
    type: {
      get () {
        return this.$store.getters[GetterNames.GetTypeMaterial].type_type
      },
      set (value) {
        this.$store.commit(MutationNames.SetTypeMaterialType, value)
      }
    },
    citation: {
      get () {
        return this.$store.getters[GetterNames.GetTypeMaterial].origin_citation_attributes
      },
      set (value) {
        this.$store.commit(MutationNames.SetTypeMaterialCitation, value)
      }
    },
    lastSave () {
      return this.$store.getters[GetterNames.GetLastSave]
    }
  },
  data () {
    return {
      types: undefined,
      sourceSelected: undefined,
      origin_citation_attributes: {
        source_id: undefined,
        pages: undefined
      }
    }
  },
  watch: {
    origin_citation_attributes: {
      handler (newVal) {
        this.citation = newVal
      },
      deep: true
    },
    lastSave (newVal) {
      this.$refs.smartSelector.refresh()
      this.$refs.sourceSmartSelector.refresh()
    }
  },
  created () {
    const urlParams = new URLSearchParams(window.location.search)
    const taxonId = urlParams.get('taxon_name_id')

    TypeMaterial.types().then(response => {
      this.types = response.body
    })

    if (/^\d+$/.test(taxonId)) {
      this.selectTaxon(taxonId)
    }
  },
  methods: {
    switchNewTaxonName () {
      window.open(`/tasks/nomenclature/new_taxon_name${this.taxon ? `?taxon_name_id=${this.taxon.id}` : ''}`, '_self')
    },
    switchBrowseNomenclature () {
      window.open(`/tasks/nomenclature/browse${this.taxon ? `?taxon_name_id=${this.taxon.id}` : ''}`, '_self')
    },
    switchTypeMaterial () {
      window.open(`/tasks/type_material/edit_type_material${this.taxon ? `?taxon_name_id=${this.taxon.id}` : ''}`, '_self')
    },
    switchBrowseOtu () {
      window.open(`/tasks/otus/browse${this.taxon ? `?taxon_name_id=${this.taxon.id}` : ''}`, '_self')
    },
    selectTaxon (taxonId) {
      this.$store.dispatch(ActionNames.GetTaxon, taxonId)
    },
    destroyTypeMateria (item) {
      if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
        this.$store.dispatch(ActionNames.RemoveTypeMaterial, item).then(() => {
          TW.workbench.alert.create('Type material was successfully destroyed.', 'notice')
        })
      }
    },
    selectSource (source) {
      this.origin_citation_attributes.source_id = source.id
      this.sourceSelected = source
    },
    newCitation () {
      this.origin_citation_attributes = {
        source_id: undefined,
        pages: undefined
      }
    },
    getOSKey: GetOSKey
  }
}
</script>
