<template>
  <div id="vue-people-uniquify">
    <div class="flex-separate middle">
      <h1>Uniquify people</h1>
      <ul class="context-menu">
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
      :legend="isLoading ? 'Loading...' : 'Merging...'"
      :logo-size="{ width: '100px', height: '100px'}"/>
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
              :disabled="!enableFindPerson"
              type="submit">Search
            </button>
          </div>
          <div class="field label-above">
            <label>Last name</label>
            <input
              class="full_width"
              type="text"
              placeholder="Search is wild card wrapped"
              v-model="lastName">
          </div>
          <div class="field label-above">
            <label>First name</label>
            <input
              class="full_width"
              type="text"
              placeholder="Search is wild card wrapped"
              v-model="firstName">
          </div>
          <div class="field">
            <label>Roles</label>
            <role-types
              v-model="selectedRoles"/>
          </div>
        </div>
      </div>
      <div class="full_width">
        <div class="horizontal-left-content align-start">
          <div class="margin-medium-right margin-medium-left">
            <div v-show="showFound">
              <h2>Select person</h2>
              <found-people
                ref="foundPeople"
                v-model="selectedPerson"
                @addToList="foundPeople.push($event)"
                :found-people="foundPeople"
                :display-count="displayCount"
              />
            </div>
            <div v-show="showMatch">
              <h2>Match people</h2>
              <match-people
                ref="matchPeople"
                v-model="mergePerson"
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
                :merge="mergePerson"/>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
// TODO:  Revise queries to bias toward last name
//        Add alternate values for names
import RoleTypes from './components/role_types'
import FoundPeople from './components/found_people'
import MatchPeople from './components/match_people'
import CompareComponent from './components/compare.vue'
import Spinner from 'components/spinner.vue'

import { GetPeopleList, PersonMerge, GetPeople } from './request/resources'

export default {
  components: {
    RoleTypes,
    FoundPeople,
    MatchPeople,
    CompareComponent,
    Spinner
  },
  computed: {
    enableFindPerson () {
      return ((this.lastName.length > 0) || (this.firstName.length > 0))
    }
  },
  data () {
    return {
      lastName: '',
      firstName: '',
      selectedRoles: [],
      isLoading: false,
      isSaving: false,
      foundPeople: [],
      selectedPerson: undefined,
      matchPeople: [],
      mergePerson: {},
      displayCount: false,
      haltWatcher: false,
      showMatch: true,
      showFound: true,
      showSearch: true
    }
  },
  methods: {
    flipPerson () {
      this.haltWatcher = true
      const tmp = this.selectedPerson
      this.selectedPerson = this.mergePerson
      this.mergePerson = tmp
    },
    findPerson (event) {
      event.preventDefault()
      const params = {
        last_name_starts_with: this.lastName,
        first_name: this.firstName,
        per: 100,
        roles: this.selectedRoles
      }

      if (!params.first_name.length) {
        delete params.first_name
      }

      this.isLoading = true
      this.clearFoundData()
      this.displayCount = true

      GetPeopleList(params).then(response => {
        this.foundPeople = response.body
        this.isLoading = false
      })
    },
    getPerson (id) {
      this.isLoading = true
      GetPeople(id).then(response => {
        this.foundPeople = [response.body]
        this.selectedPerson = response.body
        this.isLoading = false
      })
    },
    mergePeople () {
      const params = {
        person_to_destroy: this.mergePerson.id
      }
      this.isSaving = true
      PersonMerge(this.selectedPerson.id, params).then(({ body }) => {
        const personIndex = this.foundPeople.findIndex(person => person.id === this.selectedPerson.id)

        this.selectedPerson = body
        this.foundPeople = this.foundPeople.filter(people => this.mergePerson.id !== people.id)
        this.matchPeople = this.matchPeople.filter(people => this.mergePerson.id !== people.id)
        this.mergePerson = {}

        if (personIndex > -1) {
          this.$set(this.foundPeople, personIndex, this.selectedPerson)
        }

        this.isSaving = false
      })
    },
    resetApp () {
      this.clearSearchData()
      this.clearMatchData()
    },
    clearSearchData () {
      this.lastName = ''
      this.firstName = ''
      this.selectedRoles = []
      this.clearFoundData()
    },
    clearFoundData () {
      this.displayCount = false
      this.selectedPerson = undefined
      this.foundPeople = []
    },
    clearMatchData () {
      this.foundPeople = []
      this.selectedPerson = undefined
      this.matchPeople = []
      this.mergePerson = {}
    }
  },
  mounted () { // accepts only last_name param in links from other pages
    const urlParams = new URLSearchParams(window.location.search)
    const lastName = urlParams.get('last_name')
    const personId = urlParams.get('person_id')

    if (/^\d+$/.test(personId)) {
      this.getPerson(personId)
    } else if (lastName) {
      this.lastName = lastName
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
