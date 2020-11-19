<template>
  <div>
    <h2>Match people</h2>
    <spinner-component
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <p v-if="selectedPerson">{{ matchList.length }}  matches found</p>
    <div>
      <table class="full_width">
        <thead>
          <tr>
            <th></th>
            <th>Cached</th>
            <th>Lived</th>
            <th>Active</th>
            <th>Used</th>
            <th>Roles</th>
          </tr>
        </thead>
        <tbody>
          <template v-for="person in matchList">
            <tr :key="person.id">
              <td>
                <button
                  type="button"
                  class="button normal-input button-default"
                  @click="selectMergePerson(person)">
                  Select
                </button>
              </td>
              <td>{{ person.cached }}</td>
              <td>
                <span class="feedback feedback-secondary feedback-thin line-nowrap">{{ yearValue(person.year_born) }} - {{ yearValue(person.year_died) }}</span>
              </td>
              <td>
                <span class="feedback feedback-secondary feedback-thin line-nowrap">{{ yearValue(person.year_active_start) }} - {{ yearValue(person.year_active_end) }}</span>
              </td>
              <td>
                <span class="feedback feedback-thin feedback-primary">{{ person.roles.length }}</span>
              </td>
              <td>{{ getRoles(person) }}</td>
            </tr>
          </template>
        </tbody>
      </table>
    </div>
  </div>
</template>
<script>

import { GetPeople, GetPeopleList } from '../request/resources'
import SpinnerComponent from 'components/spinner'

export default {
  components: {
    SpinnerComponent
  },
  props: {
    value: {
      type: Object,
      required: true
    },
    selectedPerson: {
      type: Object,
      default: undefined
    }
  },
  computed: {
    selectedMergePerson: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    },
    matchList () {
      return this.matchPeople.filter(person => this.selectedPerson.id !== person.id)
    }
  },
  watch: {
    selectedPerson (newVal) {
      if (newVal) {
        this.getMatchPeople(newVal)
      }
    }
  },
  data () {
    return {
      isLoading: false,
      matchPeople: [],
      mergePerson: {}
    }
  },
  methods: {
    addToList (person) {
      person.cached = person.label
      this.matchPeople.push(person)
      this.selectMergePerson(person)
    },
    selectMergePerson (person) {
      GetPeople(person.id).then(response => {
        this.selectedMergePerson = response.body
      })
    },
    getMatchPeople (person) {
      if (!person && !Object.keys(person.selectedPerson).length) {
        this.mergePerson = {}
        return
      }
      this.isLoading = true
      GetPeopleList({
        name: person.cached,
        levenshtein_cuttoff: 3
      }).then(response => {
        this.isLoading = false
        this.matchPeople = response.body
      })
    },
    getRoles (person) {
      return [...new Set(person.roles.map(r => r.role_object_type))].join(', ')
    },
    yearValue (value) {
      return value || '?'
    }
  }
}
</script>

<style scoped>
.list-search {
  max-height: 500px;
  overflow-y: scroll;
}

</style>
