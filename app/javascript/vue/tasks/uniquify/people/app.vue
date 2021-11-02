<template>
  <div id="vue-people-uniquify">
    <div class="flex-separate middle">
      <h1>Uniquify people</h1>
      <ul class="context-menu">
        <li>
          <label>
            <input
              type="checkbox"
              v-model="activeJSONRequest">
            Show JSON request
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="showSearch">
            Show filter
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="showFound">
            Show found people
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="showMatch">
            Show match people
          </label>
        </li>
        <li>
          <span
            @click="resetApp"
            class="reload-app"
            data-icon="reset">Reset
          </span>
        </li>
      </ul>
    </div>
    <spinner
      v-if="isLoading || isSaving"
      :full-screen="true"
      :legend="isLoading ? 'Loading...' : `Merging... ${this.peopleRemain} persons remaining...`"
      :logo-size="{ width: '100px', height: '100px'}"/>
    <div
      v-show="activeJSONRequest"
      class="panel content separate-bottom">
      <div class="flex-separate middle">
        <span>
          JSON Request: {{ urlRequest }}
        </span>
      </div>
    </div>
    <div class="horizontal-left-content align-start">
      <div
        v-if="showSearch"
        class="panel vue-filter-container">
        <div class="flex-separate content middle action-line">
          <span>Filter</span>
        </div>
        <div class="content">
          <div class="field">
            <button
              class="button normal-input button-default full_width"
              @click="findPerson"
              type="button">Search
            </button>
            <button
              class="button normal-input button-default full_width margin-medium-top"
              type="button"
              :disabled="!selectedPerson"
              @click="getMatchPeople()">
              Update match people
            </button>
          </div>
          <in-project v-model="params.base.used_in_project_id"/>
          <h3>Person</h3>
          <name-field
            title="Name"
            param="name"
            v-model="params.base"/>
          <name-field
            title="Last name"
            param="last_name"
            :disabled="levenshteinCuttoff > 0"
            v-model="params.base"/>
          <name-field
            title="First name"
            param="first_name"
            :disabled="levenshteinCuttoff > 0"
            v-model="params.base"/>
          <active-filter v-model="params.active"/>
          <born-filter v-model="params.born"/>
          <died-filter v-model="params.died"/>
          <levenshtein-cuttoff v-model="params.base.levenshtein_cuttoff"/>
          <div class="field">
            <label>Roles</label>
            <role-types
              v-model="params.base.role"/>
          </div>
          <keywords-component
            target="People"
            v-model="params.base.keywords" />
          <users-component v-model="params.user"/>
        </div>
      </div>
      <div class="full_width">
        <div class="horizontal-left-content align-start">
          <div class="margin-medium-right margin-medium-left">
            <div v-show="showFound">
              <found-people
                ref="foundPeople"
                v-model="selectedPerson"
                @expand="expandPeople = $event"
                @addToList="foundPeople.push($event)"
                :expanded="expandPeople"
                :found-people="foundPeople"
                :display-count="displayCount"
              />
            </div>
            <div v-show="showMatch">
              <match-people
                @addToList="matchPeople.push($event)"
                v-model="mergeList"
                :match-people="matchPeople"
                :selected-person="selectedPerson"
              />
            </div>
          </div>
          <div
            class="flex-separate top">
            <div>
              <compare-component
                @flip="flipPerson"
                @merge="mergePeople"
                :selected="selectedPerson"
                :merge-list="mergeList"/>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import ActiveFilter from './components/filters/active.vue'
import BornFilter from './components/filters/born.vue'
import DiedFilter from './components/filters/died.vue'
import RoleTypes from './components/role_types'
import FoundPeople from './components/found_people'
import MatchPeople from './components/match_people'
import CompareComponent from './components/compare.vue'
import Spinner from 'components/spinner.vue'
import KeywordsComponent from 'tasks/sources/filter/components/filters/tags'
import UsersComponent from 'tasks/collection_objects/filter/components/filters/user'
import LevenshteinCuttoff from './components/filters/LevenshteinCuttoff'
import NameField from './components/filters/nameField.vue'
import InProject from './components/filters/inProject.vue'
import { People } from 'routes/endpoints'

export default {
  components: {
    ActiveFilter,
    BornFilter,
    DiedFilter,
    InProject,
    RoleTypes,
    FoundPeople,
    MatchPeople,
    CompareComponent,
    UsersComponent,
    KeywordsComponent,
    LevenshteinCuttoff,
    NameField,
    Spinner
  },
  computed: {
    levenshteinCuttoff () {
      return this.params.base.levenshtein_cuttoff
    }
  },
  data () {
    return {
      activeJSONRequest: false,
      urlRequest: undefined,
      expandPeople: true,
      isLoading: false,
      isSaving: false,
      foundPeople: [],
      selectedPerson: undefined,
      matchPeople: [],
      mergeList: [],
      mergePerson: {},
      displayCount: false,
      haltWatcher: false,
      showMatch: true,
      showFound: true,
      showSearch: true,
      peopleRemain: 0,
      params: this.initParams()
    }
  },
  watch: {
    levenshteinCuttoff (newVal) {
      if (newVal !== 0) {
        this.params.base.first_name = undefined
        this.params.base.last_name = undefined
      }
    },
    selectedPerson (newVal) {
      if (newVal) {
        this.getMatchPeople({ name: newVal.cached, levenshtein_cuttoff: 3 })
      }
    }
  },
  methods: {
    filterEmptyParams (object) {
      const keys = Object.keys(object)
      keys.forEach(key => {
        if (object[key] === '' || object[key] === undefined || (Array.isArray(object[key]) && !object[key].length)) {
          delete object[key]
        }
      })
      return object
    },
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
    flipPerson (personIndex) {
      const tmp = this.selectedPerson

      this.haltWatcher = true
      this.selectedPerson = this.mergeList[personIndex]
      this.mergeList[personIndex] = tmp
    },
    findPerson (event) {
      event.preventDefault()
      const params = this.filterEmptyParams(Object.assign({}, this.params.base, this.params.keywords, this.params.active, this.params.born, this.params.died, this.params.user, this.params.settings))

      this.clearFoundData()

      this.isLoading = true
      this.clearFoundData()
      this.displayCount = true
      this.expandPeople = true

      People.where(params).then(response => {
        this.foundPeople = response.body
        this.urlRequest = response.request.responseURL
        this.isLoading = false
      })
    },
    getPerson (id) {
      this.isLoading = true
      People.find(id).then(response => {
        this.foundPeople = [response.body]
        this.selectedPerson = response.body
        this.isLoading = false
      })
    },
    mergePeople () {
      this.peopleRemain = this.mergeList.length
      this.processMerge(this.mergeList)
    },
    processMerge (mergeList) {
      const mergePerson = mergeList.pop()
      this.isSaving = true

      People.merge(this.selectedPerson.id, { person_to_destroy: mergePerson.id }).then(({ body }) => {
        const personIndex = this.foundPeople.findIndex(person => person.id === this.selectedPerson.id)

        this.selectedPerson = body
        this.foundPeople = this.foundPeople.filter(people => mergePerson.id !== people.id)
        this.matchPeople = this.matchPeople.filter(people => mergePerson.id !== people.id)

        if (personIndex > -1) {
          this.foundPeople[personIndex] = this.selectedPerson
        }
      }).finally(() => {
        if (mergeList.length) {
          this.peopleRemain--
          this.processMerge(mergeList)
        } else {
          this.isSaving = false
        }
      })
    },
    resetApp () {
      this.clearSearchData()
      this.clearMatchData()
    },
    clearSearchData () {
      this.params = this.initParams()
      this.clearFoundData()
    },
    clearFoundData () {
      this.displayCount = false
      this.expandPeople = true
      this.selectedPerson = undefined
      this.foundPeople = []
      this.matchPeople = []
      this.mergeList = []
    },
    clearMatchData () {
      this.foundPeople = []
      this.selectedPerson = undefined
      this.matchPeople = []
      this.mergeList = []
    },
    getMatchPeople (params) {
      const data = params || this.filterEmptyParams(Object.assign({}, this.params.base, this.params.active, this.params.born, this.params.died, this.params.user, this.params.settings))
      this.mergeList = []
      People.where(data).then(response => {
        this.matchPeople = response.body
      })
    }
  },
  mounted () {
    const urlParams = new URLSearchParams(window.location.search)
    const lastName = urlParams.get('last_name')
    const personId = urlParams.get('person_id')

    if (/^\d+$/.test(personId)) {
      this.getPerson(personId)
    } else if (lastName) {
      this.params.base.last_name = lastName
      this.findPerson()
    }
  }
}
</script>

<style lang="scss">
#vue-people-uniquify {
  .merge-column {
    width: 150px;
  }

  .feedback {
    line-height: 2.5 !important;
  }
}

</style>
