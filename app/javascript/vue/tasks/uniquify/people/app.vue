<template>
  <div>
    <div class="flex-separate middle">
      <h1>Uniquify people</h1>
      <span
        @click="resetApp"
        class="reload-app"
        data-icon="reset">Reset
      </span>
    </div>
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <div class="flexbox">
      <div class="flexbox">
        <div class="first-column">
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
        <div class="found_people separate-right separate-left second-column">
          <h2>Select Person</h2>
          <found-people
            ref="foundPeople"
            v-model="selectedPerson"
            @addToList="foundPeople.push($event)"
            :found-people="foundPeople"
            :display-count="displayCount"
          />
        </div>
        <div class="match_people separate-right separate-left" >
          <h2>Match People</h2>
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

  import Spinner from '../../../components/spinner.vue'

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
        foundPeople: [],
        selectedPerson: {},
        matchPeople: [],
        mergePerson: {},
        displayCount: false,
        haltWatcher: false,
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
          last_name: this.lastName,
          first_name: this.firstName,
          roles: Object.keys(this.selectedRoles)
        };
        this.isLoading = true;
        this.clearFoundData();
        this.displayCount = true;
        let that = this;
        this.$http.get('/people.json', {params: params}).then(response => {
          this.foundPeople = response.body;
          that.isLoading = false
        })
      },
      mergePeople() {
        let params = {
          new_person_id: this.mergePerson.id
        };
        this.$http.post('/people/' + this.selectedPerson.id.toString() + '/merge', params).then(response => {
          this.$http.delete('/people/' + this.mergePerson.id).then(response => {
            this.$refs.matchPeople.removeFromList(this.mergePerson.id)    // remove the merge person from the matchPerson list
            this.$refs.foundPeople.removeFromList(this.mergePerson.id)   // remove the merge person from the foundPerson list
            this.mergePerson = {};
          })
          this.selectedPerson = response.body
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
      if (window.location.href.split('last_name=').length > 1) {
        this.lastName =  window.location.href.split('last_name=')[1].split('&')[0];
      }
    }
  }
</script>

<style lang="scss" scoped>
  .first-column, .second-column {
    width: 200px;
  }
  .merge-column {
    width: 150px;
  }
</style>
