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
              <div class="horizontal-left-content" v-if="roles.length">
                <span class="separate-left">({{ roles.length }})</span>
                <span
                  class="small-icon icon-without-space separate-left"
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
                <span
                  target="_blank"
                  v-html="citation.source.object_tag"/>
              </p>
              <div class="horizontal-left-content">
                <citation-pages
                  @setPages="addPages($event.origin_citation_attributes)"
                  :citation="taxon"/>
                <pdf-button
                  v-if="citation.hasOwnProperty('target_document')"
                  :pdf="citation.target_document"/>
                <radial-object
                  :global-id="citation.source.global_id"/>
                <radial-annotator
                  type="annotations"
                  :global-id="citation.source.global_id"/>
                <span
                  class="circle-button btn-delete"
                  @click="removeSource(taxon.origin_citation.id)"/>
              </div>
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
          <div class="flex-separate">
            <role-picker
              v-model="roles"
              @create="updateTaxonName"
              @delete="updateTaxonName"
              @sortable="updateTaxonName"
              @update="updatePersons"
              role-type="TaxonNameAuthor"/>
            <button 
              type="button"
              class="button normal-input button-submit"
              :disabled="!citation || isAlreadyClone"
              @click="cloneFromSource">
              Clone from source
            </button>
          </div>
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
import RadialAnnotator from 'components/annotator/annotator.vue'
import RadialObject from 'components/radial_object/radialObject'

export default {
  components: {
    PdfButton,
    Autocomplete,
    VerbatimAuthor,
    VerbatimYear,
    RolePicker,
    DefaultElement,
    CitationPages,
    RadialAnnotator,
    Expand,
    RadialObject
  },
  computed: {
    lastSave() {
      return this.$store.getters[GetterNames.GetLastSave]
    }, 
    citation () {
      return this.$store.getters[GetterNames.GetCitation]
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    verbatimFieldsWithData () {
      return (this.taxon.verbatim_author || this.taxon.year_of_publication)
    },
    isAlreadyClone() {
      if(this.citation.source.authors.length == 0) return true

      let authorsId = this.citation.source.authors.map(author => {
          return Number(author.object_url.split('/')[2])
      })

      let personsIds = this.roles.map(role => {
        return role.person.id
      })
      
      return authorsId.every(id => {
        return personsIds.includes(id)
      })
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
      expanded: true,
      autosave: undefined
    }
  },
  watch: {
    lastSave() {
      if (this.autosave) {
        clearTimeout(this.autosave)
        this.autosave = null
      }      
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
      this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon)
    },
    addPages (citation) {
      let that = this
      let newSource = {
        id: citation.source_id,
        pages: (citation.hasOwnProperty('pages') ? citation.pages : null)
      }
      this.$store.dispatch(ActionNames.ChangeTaxonSource, newSource)
      
      if (this.autosave) {
        clearTimeout(this.autosave)
        this.autosave = null
      }

      this.autosave = setTimeout(function () {
        that.$store.dispatch(ActionNames.UpdateTaxonName, that.taxon)
      }, 3000)
    },
    cloneFromSource() {
      let personsIds = this.roles.map(role => {
        return role.person.id
      })

      let authorsPerson = this.citation.source.authors.map(author => {
        if(!personsIds.includes(Number(author.object_url.split('/')[2]))) {
          return {
            person_id: author.object_url.split('/')[2],
            type: "TaxonNameAuthor"
          }
        }
      })
      this.roles = authorsPerson
      this.updateTaxonName()
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
