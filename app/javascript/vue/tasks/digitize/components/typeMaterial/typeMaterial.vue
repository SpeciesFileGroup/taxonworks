<template>
  <block-layout :warning="!(typeMaterial.id || typeMaterials.length)">
    <template #header>
      <h3 v-hotkey="shortcuts">Type material</h3>
    </template>
    <template #body>
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
          <button
            type="button"
            class="button circle-button button-default"
            @click="editTypeMaterial(item)">
            <v-icon
              x-small
              name="pencil"
              color="white"
            />
          </button>
          <span
            class="button circle-button btn-delete"
            @click="destroyTypeMateria(item)"/>
        </li>
      </ul>
      <div v-show="!typeMaterials.length || editMode">
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
          <template v-if="taxonSelected">
            <hr>
            <div class="flex-separate middle">
              <a
                :href="`/tasks/nomenclature/new_taxon_name?taxon_name_id=${typeMaterial.taxon.id}`"
                v-html="typeMaterial.taxon.object_tag"
              />
              <button
                type="button"
                class="button circle-button btn-undo button-default"
                @click="typeMaterial.taxon = undefined"/>
            </div>
          </template>
        </fieldset>
        <type-selector v-model="typeMaterial.type_type"/>
        <fieldset>
          <legend>Source</legend>
          <smart-selector
            ref="sourceSmartSelector"
            model="sources"
            klass="TypeMaterial"
            pin-section="Sources"
            pin-type="Source"
            label="cached"
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
    </template>
  </block-layout>
</template>

<script>

import { TypeMaterial, Source } from 'routes/endpoints'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations'
import ActionNames from '../../store/actions/actionNames.js'
import TypeSelector from './TypeSelector.vue'
import BlockLayout from 'components/layout/BlockLayout.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'
import VIcon from 'components/ui/VIcon/index'
import platformKey from 'helpers/getPlatformKey'

export default {
  components: {
    BlockLayout,
    SmartSelector,
    RadialAnnotator,
    VIcon,
    TypeSelector
  },
  computed: {
    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+m`] = this.switchTypeMaterial
      keys[`${platformKey()}+t`] = this.switchNewTaxonName
      keys[`${platformKey()}+o`] = this.switchBrowseOtu
      keys[`${platformKey()}+b`] = this.switchBrowseNomenclature

      return keys
    },

    taxonIdFormOtu () {
      const otu = this.$store.getters[GetterNames.GetTmpData].otu
      return otu?.taxon_name_id
    },

    typeMaterial: {
      get () {
        return this.$store.getters[GetterNames.GetTypeMaterial]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTypeMaterial, value)
      }
    },

    typeMaterials () {
      return this.$store.getters[GetterNames.GetTypeMaterials]
    },

    taxonSelected () {
      return this.typeMaterial.taxon
    },

    lastSave () {
      return this.$store.getters[GetterNames.GetLastSave]
    }
  },
  data () {
    return {
      editMode: false,
      types: {},
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
        this.typeMaterial.origin_citation_attributes = newVal
      },
      deep: true
    },

    lastSave () {
      this.editMode = false
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

    editTypeMaterial ({ id, origin_citation, protonym_id, type_type }) {
      if (origin_citation?.source) {
        Source.find(origin_citation.source.id).then(({ body }) => {
          this.selectSource(body)
          this.origin_citation_attributes.id = origin_citation.id
        })
      }

      this.typeMaterial.id = id
      this.selectTaxon(protonym_id)
      this.typeMaterial.type_type = type_type
      this.editMode = true
    }
  }
}
</script>
