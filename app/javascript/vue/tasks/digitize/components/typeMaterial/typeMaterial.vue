<template>
  <block-layout :warning="!(typeMaterial.id || typeMaterials.length)">
    <div slot="header">
      <h3>Type material</h3>
    </div>
    <div slot="body">
      <ul
        class="no_bullets"
        v-if="typeMaterials.length">
        <li
          v-for="item in typeMaterials"
          :key="item.id"
          class="horizontal-left-content">
          <span v-html="item.object_tag" />
          <radial-annotator
            :global-id="item.global_id"
            type="annotations"/>
          <span
            class="button circle-button btn-delete"
            @click="destroyTypeMateria(item)"/>
        </li>
      </ul>
      <template v-else>
        <div class="separate-bottom">
          <fieldset>
            <legend>Taxon name</legend>
            <smart-selector
              v-model="viewTaxon"
              class="separate-bottom item"
              name="taxon-type"
              :options="optionsTaxon"/>
            <div
              v-if="taxon"
              class="horizontal-left-content">
              <span v-html="taxon.object_tag" />
              <span
                class="button circle-button btn-undo button-default"
                @click="taxon = undefined"/>
            </div>
            <template>
              <template v-if="viewTaxon == 'search'">
                <autocomplete
                  url="/taxon_names/autocomplete"
                  min="2"
                  :clear-after="true"
                  param="term"
                  placeholder="Select a taxon name"
                  @getItem="selectTaxon($event.id)"
                  label="label_html"
                  :add-params="{
                    'type[]': 'Protonym',
                    'nomenclature_group[]': 'SpeciesGroup'
                  }"/>
              </template>
              <ul
                v-else
                class="no_bullets">
                <li
                  v-for="item in listsTaxon[viewTaxon]"
                  :key="item.id"
                  :value="item.id">
                  <label
                    @click="selectTaxon(item.id)">
                    <input
                      name="taxon-type-material"
                      :value="item.id"
                      type="radio">
                    <span v-html="item.object_tag" />
                  </label>
                </li>
              </ul>
            </template>
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
            v-model="view"
            class="separate-bottom item"
            name="source-picker"
            :options="options"/>
          <div
            v-if="view != 'search'"
            class="separate-bottom">
            <ul class="no_bullets">
              <li
                v-for="item in lists[view]"
                :key="item.id">
                <label>
                  <input
                    type="radio"
                    :value="item.id"
                    v-model="origin_citation_attributes.source_id"
                    @click="selectSource(item)">
                  {{ item.object_tag }}
                </label>
              </li>
            </ul>
          </div>
          <autocomplete
            v-else
            class="separate-bottom"
            url="/sources/autocomplete"
            placeholder="Select a source"
            param="term"
            label="label_html"
            :clear-after="true"
            @getItem="selectSource"/>

          <div
            v-if="sourceSelected"
            class="horizontal-left-content">
            <span v-html="sourceSelected.hasOwnProperty('label_html') ? sourceSelected.label_html : sourceSelected.object_tag"/>
            <span
              class="button circle-button btn-undo button-default"
              @click="newCitation(); sourceSelected = undefined"/>
          </div>
          <input
            type="text"
            v-model="origin_citation_attributes.pages"
            placeholder="Pages">
        </fieldset>
      </template>
    </div>
  </block-layout>
</template>

<script>

import Autocomplete from 'components/autocomplete.vue'
import {
  GetTaxon,
  GetTypes,
  GetTaxonNameSmartSelector,
  GetSourceSmartSelector } from '../../request/resources.js'
import ActionNames from '../../store/actions/actionNames.js'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations'
import BlockLayout from '../../../../components/blockLayout.vue'
import SmartSelector from 'components/switch.vue'
import orderSmartSelector from '../../helpers/orderSmartSelector.js'
import selectFirstSmartOption from '../../helpers/selectFirstSmartOption'
import RadialAnnotator from 'components/radials/annotator/annotator'

export default {
  components: {
    Autocomplete,
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
        this.$store.commit(MutationNames.SetTypeMaterialTaxon)
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
    }
  },
  data () {
    return {
      types: undefined,
      options: [],
      optionsTaxon: [],
      lists: {},
      listsTaxon: {},
      view: 'search',
      viewTaxon: 'search',
      sourceSelected: undefined,
      origin_citation_attributes: {
        source_id: undefined,
        pages: undefined
      }
    }
  },
  watch: {
    taxonIdFormOtu (newVal) {
      if (newVal) {
        this.getTaxon(newVal)
      }
    },
    origin_citation_attributes: {
      handler (newVal) {
        this.citation = newVal
      },
      deep: true
    }
  },
  mounted: function () {
    let urlParams = new URLSearchParams(window.location.search)
    let taxonId = urlParams.get('taxon_name_id')

    GetTypes().then(response => {
      this.types = response
    })

    GetTaxonNameSmartSelector().then(response => {
      this.optionsTaxon = orderSmartSelector(Object.keys(response))
      this.listsTaxon = response
      this.optionsTaxon.push('search')
      this.viewTaxon = selectFirstSmartOption(response, this.optionsTaxon)

      if (/^\d+$/.test(taxonId)) {
        this.selectTaxon(taxonId)
        this.getTaxon(taxonId)
      }
    })

    GetSourceSmartSelector().then(response => {
      this.options = orderSmartSelector(Object.keys(response))
      this.lists = response
      this.options.push('search')
      this.view = selectFirstSmartOption(response, this.optionsTaxon)
    })
  },
  methods: {
    getTaxon (taxonId) {
      GetTaxon(taxonId).then(response => {
        if(response.type == 'Protonym' && response.rank_string.indexOf('SpeciesGroup') > -1) {
          this.listsTaxon.quick.unshift(response)
          this.viewTaxon = 'quick'
        }
      })
    },
    selectTaxon (taxonId) {
      this.$store.dispatch(ActionNames.GetTaxon, taxonId)
    },
    destroyTypeMateria (item) {
      this.$store.dispatch(ActionNames.RemoveTypeMaterial, item).then(response => {
        TW.workbench.alert.create('Type material was successfully destroyed.', 'notice')
      })
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
    }
  }
}
</script>
