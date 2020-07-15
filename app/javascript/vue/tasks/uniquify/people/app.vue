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
            Show search
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
    <div class="horizontal-left-content">
      <div class="flexbox">
        <div
          v-show="showSearch"
          class="first-column">
          <div class="last_name separate-right">
            <h2>Search</h2>
            <h3>Last Name</h3>
            <last-name v-model="lastName"/>
          </div>
          <div class="first_name">
            <h3>First Name</h3>
            <first-name
              v-model="firstName"/>
          </div>
          <div class="role_types">
            <h3>Roles</h3>
            <role-types
              v-model="selectedRoles"/>
          </div>
          <br>
          <br>
          <br>
          <button
            class="button normal-input button-default"
            @click="findPerson"
            :disabled="!enableFindPerson"
            type="submit">Find Person
          </button>
        </div>
        <div
          v-show="showFound"
          class="found_people separate-right separate-left second-column">
          <h2>Select person</h2>
          <found-people
            ref="foundPeople"
            v-model="selectedPerson"
            @addToList="foundPeople.push($event)"
            :found-people="foundPeople"
            :display-count="displayCount"
          />
        </div>
        <div
          v-show="showMatch"
          class="match_people separate-right separate-left" >
          <h2>Match people</h2>
          <match-people
            ref="matchPeople"
            v-model="mergePerson"
            :selected-person="selectedPerson"
            @matchPeople="matchPeople = $event"
          />
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
</template>

<script>
// TODO:  Revise queries to bias toward last name
//        Add alternate values for names
  import LastName from './components/last_name'
  import FirstName from './components/first_name'
  import RoleTypes from './components/role_types'
  import FoundPeople from './components/found_people'
  import MatchPeople from './components/match_people'
  import CompareComponent from './components/compare.vue'

  import Spinner from 'components/spinner.vue'
  import AjaxCall from 'helpers/ajaxCall'

  export default {
    components: {
      LastName,
      FirstName,
      RoleTypes,
      FoundPeople,
      MatchPeople,
      CompareComponent,
      Spinner
    },
    computed: {
      enableFindPerson() {
        return ((this.lastName.length > 0) || (this.firstName.length > 0))
      },
    },
    data() {
      return {
        lastName: '',
        firstName: '',
        selectedRoles: {},
        isLoading: false,
        isSaving: false,
        foundPeople: [],
        selectedPerson: {},
        matchPeople: [],
        mergePerson: {},
        displayCount: false,
        haltWatcher: false,
        showMatch: true,
        showFound: true,
        showSearch: true
      }
    },
    watch: {
      selectedPerson() {
        if(this.haltWatcher) {
          this.haltWatcher = false
        }
        else {
          this.mergePerson = {};
          this.isLoading = true;
        }
      },
      matchPeople() {
        if(this.haltWatcher) {
          this.haltWatcher = false
        }
        else {
        this.isLoading = false;
        }
      }
    },
    methods: {
      flipPerson() {
        this.haltWatcher = true
        let tmp = this.selectedPerson
        this.selectedPerson = this.mergePerson
        this.mergePerson = tmp
      },
      findPerson() {
        let params = {
          last_name_starts_with: this.lastName,
          first_name: this.firstName,
          per: 100,
          roles: Object.keys(this.selectedRoles)
        }

        if(!params.first_name.length) {
          delete params.first_name
        }
        
        this.isLoading = true;
        this.clearFoundData();
        this.displayCount = true;
        let that = this;
        AjaxCall('get', '/people.json', {params: params}).then(response => {
          this.foundPeople = response.body;
          that.isLoading = false
        })
      },
      getPerson(id) {
        this.isLoading = true
        AjaxCall('get', `/people/${id}.json`).then(response => {
          this.foundPeople = [response.body]
          this.selectedPerson = response.body
          this.isLoading = false
        })
      },
      mergePeople() {
        let params = {
          person_to_destroy: this.mergePerson.id // this.selectedPerson.id
        };
        this.isSaving = true
        AjaxCall('post', '/people/' + this.selectedPerson.id.toString() + '/merge', params).then(response => {
          this.$refs.matchPeople.removeFromList(this.mergePerson.id)    // remove the merge person from the matchPerson list
          this.$refs.foundPeople.removeFromList(this.mergePerson.id)   // remove the merge person from the foundPerson list
          this.mergePerson = {};
          this.selectedPerson = response.body
          this.isSaving = false
        })
      },
      resetApp() {
        this.clearSearchData();
        this.clearMatchData();
      },
      clearSearchData() {
        this.lastName = '';
        this.firstName = '';
        this.selectedRoles = {};
        this.clearFoundData();
      },
      clearFoundData() {
        this.displayCount = false;
        this.selectedPerson = {};
        this.foundPeople = [];
        this.$refs.foundPeople.clearSelectedPerson()
      },
      clearMatchData() {
        this.foundPeople = [];
        this.selectedPerson = {};
        this.matchPeople = [];
        this.mergePerson = {};
      },
    },
    mounted: function() {   // accepts only last_name param in links from other pages
      let urlParams = new URLSearchParams(window.location.search)
      let lastName = urlParams.get('last_name')
      let personId = urlParams.get('person_id')

      if (/^\d+$/.test(personId)) {
        this.getPerson(personId)
      }
      else if (lastName) {
        this.lastName = lastName
        this.findPerson()
      }
    }
  }
</script>

<style lang="scss">
#vue-people-uniquify {
  .first-column, .second-column {
    width: 200px;
  }
  .merge-column {
    width: 150px;
  }

  .feedback {
    line-height: 2.5 !important;
  }
}

</style>
