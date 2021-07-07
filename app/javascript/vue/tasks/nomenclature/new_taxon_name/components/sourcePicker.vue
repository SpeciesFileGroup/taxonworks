<template>
  <block-layout
    anchor="author"
    v-help.section.author.container
    :spinner="!taxon.id"
  >
    <template #header>
      <h3>Author</h3>
    </template>
    <template #body>
      <div class="separate-bottom">
        <div class="switch-radio">
          <input
            name="author-picker-options"
            id="author-picker-source"
            checked
            type="radio"
            class="normal-input button-active"
            v-model="show"
            value="source"
          >
          <label for="author-picker-source">
            <span
              v-help.section.author.source
            >Source</span>
            <div v-if="citation">
              <span
                class="small-icon icon-without-space"
                data-icon="ok"
              />
            </div>
          </label>
          <input
            name="author-picker-options"
            id="author-picker-verbatim"
            type="radio"
            class="normal-input"
            v-model="show"
            value="verbatim"
          >
          <label
            for="author-picker-verbatim"
            v-help.section.author.verbatim
          >
            Verbatim
            <div v-if="verbatimFieldsWithData">
              <span
                class="small-icon icon-without-space"
                data-icon="ok"
              />
            </div>
          </label>
          <input
            name="author-picker-options"
            id="author-picker-person"
            type="radio"
            class="normal-input"
            v-model="show"
            value="person"
          >
          <label
            for="author-picker-person"
            v-help.section.author.person
          >
            <span>Person</span>
            <div
              class="horizontal-left-content"
              v-if="roles.length"
            >
              <span class="separate-left">({{ roles.length }})</span>
              <span
                class="small-icon icon-without-space separate-left"
                data-icon="ok"
              />
            </div>
          </label>
        </div>
      </div>
      <div v-show="show == 'source' && taxon.id">
        <div class="horizontal-left-content">
          <autocomplete
            url="/sources/autocomplete"
            min="3"
            autofocus
            param="term"
            label="label_html"
            placeholder="Type for search..."
            display="label"
            clear-after
            @getItem="setSource($event.id)"
          />
          <default-element
            v-if="!citation"
            class="margin-small-left"
            label="source"
            type="Source"
            section="Sources"
            @getId="setSource"
          />
        </div>
        <hr>
        <div v-if="citation != undefined">
          <div class="flex-separate middle">
            <p>
              <span
                target="_blank"
                v-html="citation.source.object_tag"
              />
              <soft-validation
                class="margin-small-left"
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
      <div v-show="show == 'verbatim'">
        <div class="field separate-top label-above">
          <label>Verbatim author</label>
          <verbatim-author />
        </div>
        <div class="fields label-above">
          <label>Verbatim year</label>
          <verbatim-year />
        </div>
      </div>
      <div v-show="show == 'person'">
        <div class="flex-separate">
          <role-picker
            v-model="roles"
            @create="updateLastChange"
            @delete="updateLastChange"
            @sortable="updateLastChange"
            @update="updatePersons"
            role-type="TaxonNameAuthor"
          />
          <div>
            <button
              type="button"
              class="button normal-input button-submit"
              :disabled="!citation || isAlreadyClone"
              @click="cloneFromSource"
            >
              Clone from source
            </button>
          </div>
        </div>
      </div>
    </template>
  </block-layout>
</template>

<script>

import PdfButton from 'components/pdfButton'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'

import VerbatimAuthor from './verbatimAuthor.vue'
import VerbatimYear from './verbatimYear.vue'
import CitationPages from './citationPages.vue'
import Autocomplete from 'components/ui/Autocomplete.vue'
import RolePicker from 'components/role_picker.vue'
import DefaultElement from 'components/getDefaultPin.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialObject from 'components/radials/navigation/radial'
import BlockLayout from 'components/layout/BlockLayout'
import SoftValidation from 'components/soft_validations/objectValidation.vue'

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
    RadialObject,
    BlockLayout,
    SoftValidation
  },
  computed: {
    lastSave () {
      return this.$store.getters[GetterNames.GetLastSave]
    },
    citation () {
      return this.$store.getters[GetterNames.GetCitation]
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    verbatimFieldsWithData () {
      return this.taxon.verbatim_author || this.taxon.year_of_publication
    },
    isAlreadyClone () {
      if (this.citation.source.author_roles.length === 0) return true

      const authorsId = this.citation.source.author_roles.map(author => Number(author.person.id))
      const personsIds = this.roles.map(role => role.person.id)

      return authorsId.every(id => personsIds.includes(id))
    },
    roles: {
      get () {
        const roles = this.$store.getters[GetterNames.GetRoles]

        return roles
          ? roles.sort((a, b) => a.position - b.position)
          : []
      },
      set (value) {
        this.$store.commit(MutationNames.SetRoles, value)
      }
    },
    isAutosaveActive () {
      return this.$store.getters[GetterNames.GetAutosave]
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
        id: (source?.id ? source.id : source),
        pages: (source?.pages ? source.pages : null)
      }
      this.$store.dispatch(ActionNames.ChangeTaxonSource, newSource)
      this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon)
    },
    addPages (citation) {
      const newSource = {
        id: citation.source_id,
        pages: (citation?.pages ? citation.pages : null)
      }
      this.$store.dispatch(ActionNames.ChangeTaxonSource, newSource)

      if (this.autosave) {
        clearTimeout(this.autosave)
        this.autosave = null
      }
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
    cloneFromSource () {
      const personsIds = this.roles.map(role => {
        return role.person.id
      })

      const authorsPerson = this.citation.source.author_roles.map(author => {
        if (!personsIds.includes(Number(author.person.id))) {
          return {
            person_id: author.person.id,
            type: 'TaxonNameAuthor'
          }
        }
      })
      this.roles = authorsPerson
      this.updateTaxonName()
    },
    updatePersons (list) {
      this.$store.commit(MutationNames.SetRoles, list)
    },
    removeSource (id) {
      if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
        this.$store.dispatch(ActionNames.RemoveSource, id)
      }
    },
    updateTaxonName () {
      if (this.isAutosaveActive) {
        this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon)
      }
    },
    updateLastChange () {
      this.$store.commit(MutationNames.UpdateLastChange)
    }
  }
}
</script>
