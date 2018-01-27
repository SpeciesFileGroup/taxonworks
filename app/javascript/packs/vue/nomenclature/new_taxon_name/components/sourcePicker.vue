<template>
  <form>
    <div
    class="basic-information panel">
      <a
        name="author"
        class="anchor"/>
      <div class="header flex-separate middle">
        <h3>Author</h3>
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
              <span>Source</span>
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
            <label for="author-picker-verbatim">
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
            <label for="author-picker-person">
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
                  :href="`/sources/${taxon.origin_citation.source_id}/edit`"
                  target="_blank">{{ citation.source.object_tag }}</a>
              </p>
              <citation-pages
                @setPages="addPages($event.origin_citation_attributes)"
                :citation="taxon"/>
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

const GetterNames = require('../store/getters/getters').GetterNames
const MutationNames = require('../store/mutations/mutations').MutationNames
const ActionNames = require('../store/actions/actions').ActionNames

const verbatimAuthor = require('./verbatimAuthor.vue').default
const verbatimYear = require('./verbatimYear.vue').default
const citationPages = require('./citationPages.vue').default
const autocomplete = require('../../../components/autocomplete.vue').default
const rolePicker = require('../../../components/role_picker.vue').default
const defaultElement = require('../../../components/getDefaultPin.vue').default
const expand = require('./expand.vue').default

export default {
  components: {
    autocomplete,
    verbatimAuthor,
    verbatimYear,
    rolePicker,
    defaultElement,
    citationPages,
    expand
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
