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
        <div style="width: 200px">
          <div class="last_name separate-right">
            <h2>Last Name</h2>
            <last-name v-model="lastName"/>
          </div>
          <div class="first_name separate-right separate-left">
            <h2>First Name</h2>
            <first-name
              v-model="firstName"/>
          </div>
          <div class="role_types separate-right separate-left">
            <h2>Roles</h2>
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
          class="found_people separate-right separate-left" 
          style="width: 200px">
          <h2>Select Person</h2>
          <found-people
            ref="foundPeople"
            v-model="selectedPerson"
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
          <div style="width:100px;">
            <br>
            <br>
            <br>
            <br>
            <br>
            <br>
            <button
              class="button normal-input button-default"
              @click="mergePeople"
              :disabled="!enableMerge"
              type="submit">Merge People
            </button>
          </div>
          <div 
            style="overflow: auto; width:300px; height:600px;">
            <h2>Selected Person</h2>
            <pre>{{ selectedPerson }}</pre>
          </div>
          <div 
            style="overflow: auto; width:300px; height:600px;">
            <h2>Merge Person</h2>
            <pre>{{ mergePerson }}</pre>
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

  import Spinner from '../../../components/spinner.vue'

  export default {
    components: {
      LastName,
      FirstName,
      RoleTypes,
      FoundPeople,
      MatchPeople,
      Spinner
    },
    computed: {
      enableFindPerson() {
        return ((this.lastName.length > 0) || (this.firstName.length > 0))
      },
      enableMerge() {
        return Object.keys(this.mergePerson).length
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
        displayCount: false
      }
    },
    watch: {
      selectedPerson() {
        this.mergePerson = {};
        this.isLoading = true;
      },
      matchPeople() {
        this.isLoading = false;
      }
    },
    methods: {
      findPerson() {
        let params = {
          lastname: this.lastName,
          firstname: this.firstName,
          roles: Object.keys(this.selectedRoles)
        };
        this.isLoading = true;
        this.displayCount = true;
        let that = this;
        this.$http.get('/people.json', {params: params}).then(response => {
          this.foundPeople = response.body;
          that.isLoading = false
          // that.clearMatchData();
          // console.log(this.foundPeople);
        })
      },
      mergePeople() {
        let params = {
          new_person_id: this.mergePerson.id
        };
        this.$http.post('/people/' + this.selectedPerson.id.toString() + '/merge', params).then(response => {
          let httpStatus = response.body;
          if (httpStatus.status == 'OK') {   // delete the merged in person and refresh the merged to person            
            this.$http.delete('/people/' + this.mergePerson.id).then(response => {
            this.$refs.matchPeople.removeFromList(this.mergePerson.id)    // remove the merge person from the matchPerson list
            this.$refs.foundPeople.removeFromList(this.mergePerson.id)   // remove the merge person from the foundPerson list
            this.mergePerson = {};
          })
          }
          else {    // TODO: Annunciate delete failure more gracefully
            alert(httpStatus.status);
            this.mergePerson = {};
          }
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
        this.displayCount = false;
        this.selectedPerson = {};
      },
      clearMatchData() {
        this.foundPeople = [];
        this.selectedPerson = {};
        this.$refs.foundPeople.clearSelectedPerson();
        this.matchPeople = [];
        this.mergePerson = {};
      },
    }
  }
</script>
