<template>
  <div>
    <div class="horizontal-left-content middle">
      <h2>Select person</h2>
      <a
        class="cursor-pointer margin-small-left"
        v-if="!expanded"
        @click="$emit('expand', true)">Expand
      </a>
    </div>
    <p v-if="displayCount">{{ foundPeople.length }} people found</p>
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
        <tbody v-if="expanded">
          <template v-for="person in foundPeople">
            <tr
              v-if="person.id != selected['id']"
              :key="person.id">
              <td>
                <button
                  type="button"
                  class="button normal-input button-default"
                  @click="selectPerson(person)">
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

import { GetPeople } from '../request/resources'

export default {
  props: {
    value: {
      type: Object,
      default: undefined
    },
    foundPeople: {
      type: Array,
      default: () => { return [] }
    },
    displayCount: {
      type: Boolean,
      default: false
    },
    expanded: {
      type: Boolean,
      default: true
    }
  },
  computed: {
    selectedPerson: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data() {
    return {
      selected: {}
    }
  },
  methods: {
    removeFromList(personID) {
      const index = this.foundPeople.findIndex(item => {
        return item.id === personID
      })

      if (index > -1) {
        this.foundPeople.splice(index, 1)
      }
    },
    addToList(person) {
      this.selectPerson(person)
      person.cached = person.label
      this.$emit('addToList', person)
      this.selected = person
    },
    selectPerson (person) {
      GetPeople(person.id).then(response => {
        this.selectedPerson = response.body
        this.$emit('expand', false)
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
