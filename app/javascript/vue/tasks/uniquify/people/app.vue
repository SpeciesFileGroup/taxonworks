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
          <button
              class="button normal-input button-default"
              @click="findPerson"
              :disabled="!enableFindPerson"
              type="submit">Find Person
          </button>
        </div>
        <div class="found_people separate-right separate-left" style="width: 200px">
          <h2>Select person</h2>
          <found-people
              v-model="selectedPerson"
              :found-people="foundPeople"
          />
        </div>
        <div class="match_people separate-right separate-left" style="width: 200px">
          <h2>Match People</h2>
          <match-people
              ref="matchPeople"
              v-model="mergePerson"
              :selected-person="selectedPerson"
          />
        </div>
      </div>
      <div class="flex-separate middle">
        <div class="selected_person separate-right separate-left" style="overflow: auto; width:300px; height:600px;">
          <h2>Selected Person</h2>
          <selected-person
              :selected-person="selectedPerson"
          />
        </div>
        <div class="merge_person separate-right separate-left" style="overflow: auto; width:300px; height:600px;">
          <h2>Merge Person</h2>
          <merge-person
              :merge-person="mergePerson"
          />
        </div>
        <button
            class="button normal-input button-default"
            @click="mergePeople"
            :disabled="!enableMerge"
            type="submit">Merge People
        </button>
      </div>
    </div>
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
  import SelectedPerson from './components/selected_person'
  import MatchPeople from './components/match_people'
  import MergePerson from './components/merge_person'

  import Spinner from '../../../components/spinner.vue'

  export default {
    components: {
      LastName,
      FirstName,
      RoleTypes,
      FoundPeople,
      SelectedPerson,
      MatchPeople,
      MergePerson,
      Spinner
    },
    computed: {
      enableFindPerson() {
        return ((this.lastName.length > 0) || (this.firstName.length > 0))
      },
      enableMerge() {
        return ((this.mergePerson) && (this.selectedPerson))
      },
      // selectedPersonString() {
      //   return this.prettyString(this.selectedPerson)
      //   // JSON.stringify(JSON.parse(this.selectedPerson), null, 2)
      // },
      // mergePersonString() {
      //   return this.prettyString(this.mergePerson)
      //   // JSON.stringify(JSON.parse(this.mergePerson), null, 2)
      // }
    },
    data() {
      return {
        lastName: '',
        firstName: '',
        selectedRoles: {},
        // filter: this.resetFilter(),
        isLoading: false,
        foundPeople: [],
        selectedPerson: {},
        matchPeople: [],
        mergePerson: {},
        // request: {
        //   url: '',
        //   total: 0
        // },
      }
    },
    methods: {
      findPerson() {
        let params = {
          lastname: this.lastName,
          firstname: this.firstName,
          roles: Object.keys(this.selectedRoles)
        };
        this.$http.get('/people.json', {params: params}).then(response => {
          this.foundPeople = response.body;
          console.log(this.foundPeople);
        })
      },
      mergePeople() {
        let params = {
          old_person_id: this.selectedPerson.id,
          new_person_id: this.mergePerson.id
        };
        this.$http.post('/people/' + this.selectedPerson.id.toString() + '/merge', {new_person_id: this.mergePerson.id}).then(response => {
          console.log(response.bodyText);
          this.$http.delete('/people/' + this.mergePerson.id).then( response => {
            console.log('DELETED: ' + this.mergePerson.id);
            this.$refs.matchPeople.removeFromList(this.mergePerson.id)
          })
        })
      },
      resetApp() {
        this.filter = this.resetFilter();
        this.foundPeople = [];
        this.matchPeople = [];
        this.nergePerson = {};
        this.selectedPerson = {};
        // this.request.url = '';
        // this.request.total = 0
      },
      // prettyString(uglyJSON) {
      //   return JSON.stringify(uglyJSON, null, 2)
      // },
      // resetFilter() {
      //   return true
      // }
    }
  }
</script>
