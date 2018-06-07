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
      <div class="last_name separate-right">
        <h2>Last Name</h2>
        <last-name v-model="filter.last_name"/>
      </div>
      <div class="first_name separate-right separate-left">
        <h2>First Name</h2>
        <first-name
            v-model="filter.first_name"
            :first-name="filter.first_name"/>
      </div>
      <div class="role_types separate-right separate-left">
        <h2>Roles</h2>
        <role-types
            v-model="filter.foundPeople"
            @selected_for="filter.selectedPerson = $event"/>
      </div>
      <div class="found_people separate-right separate-left">
        <h2>Select person</h2>
        <found-people v-model="filter.found_people"/>
      </div>
      <div class="match_people separate-right separate-left">
        <h2>Match people</h2>
        <match-people v-model="filter.match_people"/>
      </div>
    </div>
    <button
        class="button normal-input button-default"
        @click="findPerson"
        :disabled="submitAvailable"
        type="submit">Find Person
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
      submitAvailable() {
        return true;  //!this.filter.annotation_type.type || !this.filter.model
      }
    },
    data() {
      return {
        selectedPerson: {},
        roletypes: {},
        filter: this.resetFilter(),
        isLoading: false,
        foundPeople: [],
        matchPeople: [],
        mergePeople: [],
        request: {
          url: '',
          total: 0
        },
      }
    },
    methods: {
      findPerson() {

      },
      resetApp() {
        this.filter = this.resetFilter()
        this.foundPeople = []
        this.matchPeople = []
        this.mergePeople = []
        this.request.url = ''
        this.request.total = 0
      },
      resetFilter() {
        return true
      }
    }
  }
</script>