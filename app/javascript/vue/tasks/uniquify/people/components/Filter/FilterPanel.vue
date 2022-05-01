<template>
  <div class="panel vue-filter-container">
    <div class="flex-separate content middle action-line">
      <span>Filter</span>
    </div>
    <div class="content">
      <div class="field">
        <button
          class="button normal-input button-default full_width"
          type="button"
          @click="$emit('findPeople', parsedParams)"
        >
          Selected person
        </button>
        <button
          class="button normal-input button-default full_width margin-medium-top"
          type="button"
          :disabled="disabledMatch"
          @click="$emit('matchPeople', parsedParams)"
        >
          Match people
        </button>
      </div>
      <facet-in-project v-model="params.base.used_in_project_id" />
      <h3>Person</h3>
      <facet-name-field
        title="Name"
        param="name"
        v-model="params.base"
      />
      <facet-name-field
        title="Last name"
        param="last_name"
        :disabled="params.base.levenshtein_cuttoff > 0"
        v-model="params.base"
      />
      <facet-name-field
        title="First name"
        param="first_name"
        :disabled="params.base.levenshtein_cuttoff > 0"
        v-model="params.base"
      />
      <facet-active v-model="params.active" />
      <facet-born v-model="params.born" />
      <facet-died v-model="params.died" />
      <facet-levenshtein-cuttoff v-model="params.base.levenshtein_cuttoff" />
      <facet-role-types v-model="params.base.role" />
      <keywords-component
        target="People"
        v-model="params.base.keywords"
      />
      <users-component v-model="params.user" />
    </div>
  </div>
</template>

<script>

import FacetActive from './Facets/FacetActive.vue'
import FacetBorn from './Facets/FacetBorn.vue'
import FacetDied from './Facets/FacetDied.vue'
import FacetRoleTypes from './Facets/FacetRoleType.vue'
import KeywordsComponent from 'tasks/sources/filter/components/filters/tags'
import UsersComponent from 'tasks/collection_objects/filter/components/filters/user'
import FacetLevenshteinCuttoff from './Facets/FacetLevenshteinCuttoff.vue'
import FacetNameField from './Facets/FacetNameField.vue'
import FacetInProject from './Facets/FacetInProject.vue'

export default {
  components: {
    FacetActive,
    FacetBorn,
    FacetDied,
    FacetRoleTypes,
    KeywordsComponent,
    UsersComponent,
    FacetLevenshteinCuttoff,
    FacetNameField,
    FacetInProject
  },

  props: {
    disabledMatch: {
      type: Boolean,
      default: false
    }
  },

  emits: [
    'findPeople',
    'matchPeople'
  ],

  data () {
    return {
      params: this.initParams()
    }
  },

  computed: {
    parsedParams () {
      return this.filterEmptyParams({
        ...this.params.base,
        ...this.params.keywords,
        ...this.params.active,
        ...this.params.born,
        ...this.params.died,
        ...this.params.user,
        ...this.params.settings
      })
    }
  },

  watch: {
    levenshteinCuttoff (newVal) {
      if (newVal !== 0) {
        this.params.base.first_name = undefined
        this.params.base.last_name = undefined
      }
    }
  },

  methods: {
    initParams () {
      return {
        settings: {
          per: 100
        },
        base: {
          levenshtein_cuttoff: undefined,
          last_name: '',
          first_name: '',
          role: [],
          person_wildcard: [],
          used_in_project_id: []
        },
        keywords: {
          keyword_id_and: [],
          keyword_id_or: []
        },
        active: {
          active_before_year: undefined,
          active_after_year: undefined
        },
        born: {
          born_before_year: undefined,
          born_after_year: undefined
        },
        died: {
          died_before_year: undefined,
          died_after_year: undefined
        },
        user: {
          user_id: undefined,
          user_target: undefined,
          user_date_start: undefined,
          user_date_end: undefined
        }
      }
    },

    filterEmptyParams (object) {
      const keys = Object.keys(object)

      keys.forEach(key => {
        if (object[key] === '') {
          delete object[key]
        }
      })
      return object
    },

    resetFilter () {
      this.params = this.initParams()
    }
  }
}
</script>
