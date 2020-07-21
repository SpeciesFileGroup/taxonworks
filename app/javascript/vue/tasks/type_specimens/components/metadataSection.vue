<template>
  <div class="panel type-specimen-box">
    <spinner
      :show-spinner="false"
      :show-legend="false"
      v-if="!protonymId"/>
    <div class="header flex-separate middle">
      <h3>Metadata</h3>
      <expand v-model="displayBody"/>
    </div>
    <div
      class="body"
      v-if="displayBody">
      <label>Type</label>
      <div class="flex-wrap-row separate-top separate-bottom">
        <template v-if="checkForTypeList">
          <ul class="flex-wrap-column no_bullets">
            <li
              v-for="(item, key) in types[taxon.nomenclatural_code]"
              :key="key">
              <label class="capitalize">
                <input
                  v-model="type"
                  type="radio"
                  name="typetype"
                  :value="key">
                {{ key }}
              </label>
            </li>
          </ul>
        </template>
      </div>
      <div class="field">
        <fieldset v-if="!citationCreated">
          <legend>Source</legend>
          <smart-selector
            model="sources"
            klass="CollectionObject"
            pin-section="Sources"
            pin-type="Source"
            @selected="selectSource"
          >
            <div slot="body">
              <p
                v-if="showSource && citation.source_id"
                class="horizontal-left-content">
                <span v-html="showSource"/>
                <span
                  class="circle-button button-default btn-undo"
                  @click="resetCitation"/>
              </p>
            </div>
            <div slot="footer">
              <ul class="no_bullets context-menu">
                <li>
                  <input
                    type="text"
                    v-model="citation.pages"
                    placeholder="Pages">
                </li>
                <li>
                  <label>
                    <input
                      type="checkbox"
                      v-model="citation.is_original">
                    Is original
                  </label>
                </li>
              </ul>
            </div>
          </smart-selector>
        </fieldset>
        <div
          v-else
          class="horizontal-left-content">
          <span>
            <span v-html="typeMaterial.origin_citation.object_tag"/>
            <soft-validation
              class="margin-small-left"
              :global-id="typeMaterial.origin_citation.global_id"/>
          </span>
          <span
            class="circle-button btn-delete"
            @click="removeCitation"/>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import Expand from './expand.vue'
import SmartSelector from 'components/smartSelector'
import Spinner from 'components/spinner.vue'
import SoftValidation from 'components/soft_validations/objectValidation.vue'

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { GetTypes, GetSource, DestroyCitation } from '../request/resources'

export default {
  components: {
    Spinner,
    Expand,
    SmartSelector,
    SoftValidation
  },
  computed: {
    citation: {
      get () {
        return this.$store.getters[GetterNames.GetTypeMaterial].origin_citation_attributes
      },
      set (value) {
        this.$store.commit(MutationNames.SetCitation, value)
      }
    },
    type: {
      get () {
        return this.$store.getters[GetterNames.GetType]
      },
      set (value) {
        this.$store.commit(MutationNames.SetType, value)
      }
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    protonymId () {
      return this.$store.getters[GetterNames.GetProtonymId]
    },
    checkForTypeList () {
      return this.types && this.taxon
    },
    typeMaterial: {
      get () {
        return this.$store.getters[GetterNames.GetTypeMaterial]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTypeMaterial)
      }
    },
    citationCreated () {
      return this.typeMaterial.hasOwnProperty('origin_citation') && this.typeMaterial.origin_citation
    }
  },
  data: function () {
    return {
      displayBody: true,
      types: undefined,
      showSource: undefined
    }
  },
  watch: {
    citation: {
      handler (newVal, oldVal) {
        if(newVal.source_id && newVal.source_id !== oldVal.source_id) {
          GetSource(newVal.source_id).then(response => {
            this.showSource = response.body.object_tag
          })
        }
      },
      deep: true
    }
  },
  mounted: function () {
    GetTypes().then(response => {
      this.types = response.body
    })
  },
  methods: {
    resetCitation () {
      this.showSource = undefined
      this.citation = {
        source_id: undefined, 
        pages: undefined
      }
    },
    removeCitation () {
      DestroyCitation(this.typeMaterial.origin_citation.id).then(response => {
        this.typeMaterial.origin_citation = undefined
      })
    },
    selectSource (source) {
      this.citation.source_id = source.id
      this.showSource = source.object_tag
    }
  }
}
</script>
