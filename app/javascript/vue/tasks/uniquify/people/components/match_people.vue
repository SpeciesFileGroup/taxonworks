<template>
  <div>
    <h2>Match people</h2>
    <p v-if="selectedPerson">
      {{ matchList.length }}  matches found
    </p>
    <div>
      <autocomplete
        url="/people/autocomplete"
        param="term"
        label="label_html"
        placeholder="Search a person..."
        clear-after
        @get-item="addToList"
      />
      <table class="full_width">
        <thead>
          <tr>
            <th>
              <input
                v-model="selectAll"
                type="checkbox"
              >
            </th>
            <th>Cached</th>
            <th>Lived</th>
            <th>Active</th>
            <th>Used</th>
            <th>Roles</th>
          </tr>
        </thead>
        <tbody>
          <template
            v-for="person in matchList"
            :key="person.id"
          >
            <tr>
              <td>
                <input
                  type="checkbox"
                  :value="person"
                  v-model="selectedMergePerson"
                >
              </td>
              <td>{{ person.cached }}</td>
              <td>
                <span class="feedback feedback-secondary feedback-thin line-nowrap">{{ yearValue(person.year_born) }} - {{ yearValue(person.year_died) }}</span>
              </td>
              <td>
                <span class="feedback feedback-secondary feedback-thin line-nowrap">{{ yearValue(person.year_active_start) }} - {{ yearValue(person.year_active_end) }}</span>
              </td>
              <td>
                <span class="feedback feedback-thin feedback-primary">{{ person.roles ? person.roles.length : '?' }}</span>
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

import { People } from 'routes/endpoints'
import Autocomplete from 'components/ui/Autocomplete'

export default {
  components: { Autocomplete },

  props: {
    modelValue: {
      type: Array,
      required: true
    },

    selectedPerson: {
      type: Object,
      default: undefined
    },

    matchPeople: {
      type: Array,
      required: true
    }
  },

  emits: [
    'update:modelValue',
    'addToList'
  ],

  computed: {
    selectedMergePerson: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    },

    selectAll: {
      get () {
        return this.matchList.length && this.selectedMergePerson.length === this.matchList.length
      },
      set (value) {
        this.selectedMergePerson = value ? this.matchList : []
      }
    },

    matchList () {
      return this.matchPeople.filter(person => this.selectedPerson.id !== person.id)
    }
  },

  methods: {
    addToList (person) {
      person.cached = person.label
      People.find(person.id, { extend: ['roles'] }).then(response => {
        if (!this.selectedMergePerson.find(p => p.id === response.body.id)) {
          this.selectedMergePerson.push(response.body)
          this.$emit('addToList', response.body)
        }
      })
    },

    getRoles (person) {
      return person.roles ? [...new Set(person.roles.map(r => r.role_object_type))].join(', ') : ''
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
