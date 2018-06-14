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
      <div>
        <div class="last_name separate-right">
          <h2>Last Name</h2>
          <last-name v-model="lastName"/>
        </div>
        <div class="first_name separate-right separate-left">
          <h2>First Name</h2>
          <first-name
            v-model="firstName" />
        </div>
        <div class="role_types separate-right separate-left">
          <h2>Roles</h2>
          <role-types
            v-model="selectedRoles" />
        </div>
        <button
            class="button normal-input button-default"
            @click="findPerson"
            :disabled="!submitAvailable"
            type="submit">Find Person
        </button>
      </div>
      <div class="found_people separate-right separate-left">
        <h2>Select person</h2>
        <found-people
          v-model="selectedPerson"
          :found-people="foundPeople"
        />
      </div>
      <div class="selected_person">
        <h2>Selected Person</h2>
        <selected-person
          :selected-person="selectedPerson"
        />
      </div>
      <div class="match_people separate-right separate-left">
        <h2>Match people</h2>
        <match-people
          v-model="matchPeople"/>
      </div>
    </div>
    <button
        class="button normal-input button-default"
        @click="mergePeople"
        :disabled="submitAvailable"
        type="submit">Merge People
    </button>
    <!--<request-bar-->
    <!--:url="request.url"-->
    <!--:total="request.total"/>-->
    <!--<view-list-->
    <!--:list="resultList"/>-->
  </div>
</template>

<script>
  import LastName from './components/last_name'
  import FirstName from './components/first_name'
  import RoleTypes from './components/role_types'
  import FoundPeople from './components/found_people'
  import SelectedPerson from'./components/selected_person'
  import MatchPeople from './components/match_people'

  import Spinner from '../../../components/spinner.vue'

  export default {
    components: {
      LastName,
      FirstName,
      RoleTypes,
      FoundPeople,
      SelectedPerson,
      MatchPeople,
      Spinner
    },
    computed: {
      submitAvailable() {
        return (this.lastName.length > 2) //|| !this.filter.model
      }
    },
    data() {
      return {
        selectedPerson: {},
        lastName: '',
        firstName: '',
        selectedRoles: {},
        filter: this.resetFilter(),
        isLoading: false,
        foundPeople: [],
        selectedPerson: {},
        matchPeople: {},
        mergedPeople: {},
        request: {
          url: '',
          total: 0
        },
      }
    },
    methods: {
      findPerson() {
        // TODO: make the request of the endpoint
        // send last name, first name, roles to endpoint
        let params = {
          lastname: this.lastName,
          firstname: this.firstName,
          roles: Object.keys(this.selectedRoles)
        }
        this.$http.get('/people.json', {params: params} ).then(response => {
          this.foundPeople = response.body;
          console.log(this.foundPeople);
        })
      },
      mergePeople() {
        // TODO: merge the selected people to/with the selected person
      },
      resetApp() {
        this.filter = this.resetFilter()
        this.foundPeople = [];
        this.matchPeople = {};
        this.mergedPeople = {};
        this.request.url = '';
        this.request.total = 0
      },
      resetFilter() {
        return true
      }
    }
  }
</script>
