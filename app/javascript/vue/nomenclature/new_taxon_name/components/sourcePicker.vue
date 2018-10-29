<template>
  <form>
    <div
      class="basic-information panel">
      <a
        name="author"
        class="anchor"/>
      <div class="header flex-separate middle">
      <h3
      v-help.section.author.container
      >Author</h3>
        <expand
          @changed="expanded = !expanded"
          :expanded="expanded"/>
      </div>
      <div
        class="body"
        v-show="expanded">
        <div class="separate-bottom">
          <div class="switch-radio">
            <input
              name="author-picker-options"
              id="author-picker-source"
              checked
              type="radio"
              class="normal-input button-active"
              v-model="show"
              value="source">
            <label for="author-picker-source">
            <span
            v-help.section.author.source
             >Source</span>
              <div v-if="citation">
                <span
                  class="small-icon icon-without-space"
                  data-icon="ok"/>
              </div>
            </label>
            <input
              name="author-picker-options"
              id="author-picker-verbatim"
              type="radio"
              class="normal-input"
              v-model="show" 
              value="verbatim">
            <label
              for="author-picker-verbatim"
              v-help.section.author.verbatim> 
              Verbatim
              <div v-if="verbatimFieldsWithData">
                <span
                  class="small-icon icon-without-space"
                  data-icon="ok"/>
              </div>
            </label>
            <input
              name="author-picker-options"
              id="author-picker-person"
              type="radio"
              class="normal-input"
              v-model="show"
              value="person">
            <label
              for="author-picker-person"
              v-help.section.author.person>
              <span>Person</span>
              <div v-if="roles.length">
                ({{ roles.length }})
                <span
                  class="small-icon icon-without-space"
                  data-icon="ok"/>
              </div>
            </label>
          </div>
        </div>
        <div v-if="show == 'source' && taxon.id">
          <div class="horizontal-left-content">
            <autocomplete
              url="/sources/autocomplete"
              min="3"
              :autofocus="true"
              param="term"
              event-send="sourceSelect"
              label="label_html"
              placeholder="Type for search..."
              display="label"/>
            <default-element
              v-if="!citation"
              label="source"
              type="Source"
              section="Sources"
              @getId="setSource"/>
          </div>
          <hr>
          <div v-if="citation != undefined">
            <div class="flex-separate middle">
              <p>
                <a
                  :href="`/sources/${taxon.origin_citation.source.id}/edit`"
                  target="_blank">{{ citation.source.object_tag }}</a>
              </p>
              <citation-pages
                @setPages="addPages($event.origin_citation_attributes)"
                :citation="taxon"/>
              <pdf-button
                v-if="citation.hasOwnProperty('target_document')"
                :pdf="citation.target_document"/>
              <span
                class="circle-button btn-delete"
                @click="removeSource(taxon.origin_citation.id)"/>
            </div>
          </div>
        </div>
        <div v-if="show == 'verbatim'">
          <div class="field separate-top">
            <label>Verbatim author</label><br>
            <verbatim-author/>
          </div>
          <div class="fields">
            <label>Verbatim year</label><br>
            <verbatim-year/>
          </div>
        </div>
        <div v-if="show == 'person'">
          <role-picker
            v-model="roles"
            @create="updateTaxonName"
            @delete="updateTaxonName"
            @sortable="updateTaxonName"
            @update="updatePersons"
            role-type="TaxonNameAuthor"/>
        </div>
      </div>
    </div>
  </form>
</template>

<script>

import PdfButton from 'components/pdfButton'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'

import VerbatimAuthor from './verbatimAuthor.vue'
import VerbatimYear from './verbatimYear.vue'
import CitationPages from './citationPages.vue'
import Autocomplete from 'components/autocomplete.vue'
import RolePicker from 'components/role_picker.vue'
import DefaultElement from 'components/getDefaultPin.vue'
import Expand from './expand.vue'

export default {
  components: {
    PdfButton,
    Autocomplete,
    VerbatimAuthor,
    VerbatimYear,
    RolePicker,
    DefaultElement,
    CitationPages,
    Expand
  },
  computed: {
    citation () {
      return this.$store.getters[GetterNames.GetCitation]
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    verbatimFieldsWithData () {
      return (this.taxon.verbatim_author || this.taxon.year_of_publication)
    },
    roles: {
      get () {
        if (this.$store.getters[GetterNames.GetRoles] == undefined) return []
        return this.$store.getters[GetterNames.GetRoles].sort(function (a, b) {
          return (a.position - b.position)
        })
      },
      set (value) {
        this.$store.commit(MutationNames.SetRoles, value)
      }
    }
  },
  data: function () {
    return {
      show: 'source',
      expanded: true
    }
  },
  mounted: function () {
    this.$on('sourceSelect', function (value) {
      this.setSource(value)
    })
  },
  methods: {
    setSource: function (source) {
      let newSource = {
        id: (source.hasOwnProperty('id') ? source.id : source),
        pages: (source.hasOwnProperty('pages') ? source.pages : null)
      }
      this.$store.dispatch(ActionNames.ChangeTaxonSource, newSource)
    },
    addPages (citation) {
      let newSource = {
        id: citation.source_id,
        pages: (citation.hasOwnProperty('pages') ? citation.pages : null)
      }
      this.$store.dispatch(ActionNames.ChangeTaxonSource, newSource)
    },
    updatePersons: function (list) {
      this.$store.commit(MutationNames.SetRoles, list)
    },
    removeSource: function (id) {
      this.$store.dispatch(ActionNames.RemoveSource, id)
    },
    updateTaxonName: function () {
      this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon)
    }
  }
}
</script>
