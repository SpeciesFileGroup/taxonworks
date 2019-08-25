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
            <li v-for="(item, key) in types[taxon.nomenclatural_code]">
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
        <label>Source</label>
        <div
          v-if="!citationCreated"
          class="horizontal-left-content">
          <autocomplete
            class="separate-right"
            url="/sources/autocomplete"
            label="label_html"
            param="term"
            :clear-after="true"
            min="2"
            placeholder="Select a source"
            @getItem="citation.source_id = $event.id; showSource = $event.label_html"/>
          <input
            type="text"
            v-model="citation.pages"
            placeholder="Pages">
        </div>
        <div
          class="horizontal-left-content">
          <template v-if="citationCreated">
            <span v-html="typeMaterial.origin_citation.object_tag"/>
            <span
              class="circle-button btn-delete"
              @click="removeCitation"/>
          </template>
          <template v-else>
            <template v-if="showSource && citation.source_id">
              <span v-html="showSource"/>
              <span
                class="circle-button button-default btn-undo"
                @click="resetCitation"/>
            </template>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import Expand from './expand.vue'
import Autocomplete from 'components/autocomplete.vue'
import Spinner from 'components/spinner.vue'

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { GetTypes, GetSource, DestroyCitation } from '../request/resources'

export default {
  components: {
    Autocomplete,
    Spinner,
    Expand
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
            this.showSource = response.object_tag
          })
        }
      },
      deep: true
    }
  },
  mounted: function () {
    GetTypes().then(response => {
      this.types = response
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
    }
  }
}
</script>
<style lang="scss" scoped>
/deep/ .vue-autocomplete-input {
  width: 400px;
}
</style>