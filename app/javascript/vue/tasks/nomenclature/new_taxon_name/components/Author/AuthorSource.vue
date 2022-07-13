<template>
  <div class="full_width">
    <div class="horizontal-left-content full_width">
      <autocomplete
        url="/sources/autocomplete"
        min="3"
        param="term"
        label="label_html"
        placeholder="Type for search..."
        display="label"
        clear-after
        @getItem="setSource($event.id)"
      />
      <default-element
        class="margin-small-left"
        label="source"
        type="Source"
        section="Sources"
        @getId="setSource"
      />
    </div>
    <hr>
    <div v-if="citation">
      <div class="flex-separate middle">
        <p>
          <span
            target="_blank"
            v-html="citation.source.cached"
          />
          <soft-validation
            :validate-object="citation"
            :global-id="citation.global_id"/>
        </p>
        <div class="horizontal-left-content">
          <citation-pages
            @setPages="addPages"
            @save="triggerSave"
            :citation="taxon"
          />
          <pdf-button
            v-if="citation.hasOwnProperty('target_document')"
            :pdf="citation.target_document"
          />
          <radial-object
            :global-id="citation.source.global_id"
          />
          <radial-annotator
            type="annotations"
            :global-id="citation.source.global_id"
          />
          <span
            class="circle-button btn-delete"
            @click="removeSource(taxon.origin_citation.id)"
          />
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

import Autocomplete from 'components/ui/Autocomplete.vue'
import DefaultElement from 'components/getDefaultPin.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialObject from 'components/radials/navigation/radial'
import PdfButton from 'components/pdfButton'
import CitationPages from '../citationPages.vue'
import SoftValidation from 'components/soft_validations/objectValidation.vue'

export default {
  components: {
    Autocomplete,
    CitationPages,
    DefaultElement,
    RadialAnnotator,
    RadialObject,
    PdfButton,
    SoftValidation
  },

  data () {
    return {
      autosave: undefined
    }
  },

  computed: {
    citation () {
      return this.$store.getters[GetterNames.GetCitation]
    },

    taxon: {
      get () {
        return this.$store.getters[GetterNames.GetTaxon]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxon, value)
      }
    },

    isAutosaveActive () {
      return this.$store.getters[GetterNames.GetAutosave]
    },
  },

  watch: {
    lastSave () {
      if (this.autosave) {
        clearTimeout(this.autosave)
        this.autosave = null
      }
    }
  },

  methods: {
    setSource (source) {
      const newSource = {
        id: source?.id || source,
        pages: this.citation?.pages || null
      }
      this.$store.dispatch(ActionNames.ChangeTaxonSource, newSource)
      this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon)
    },

    addPages (citation) {
      const newSource = {
        id: citation.source_id,
        pages: citation?.pages || null
      }
      this.$store.dispatch(ActionNames.ChangeTaxonSource, newSource)

      clearTimeout(this.autosave)

      if (this.isAutosaveActive) {
        this.autosave = setTimeout(() => {
          this.triggerSave(citation)
        }, 3000)
      }
    },

    triggerSave (citation) {
      clearTimeout(this.autosave)
      this.$store.dispatch(ActionNames.UpdateSource, citation)
    },

    removeSource (id) {
      if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
        this.$store.dispatch(ActionNames.RemoveSource, id)
      }
    }
  }
}
</script>
