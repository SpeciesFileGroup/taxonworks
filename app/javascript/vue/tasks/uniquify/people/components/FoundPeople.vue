<template>
  <div>
    <div class="horizontal-left-content middle">
      <h2>Select person</h2>
    </div>
    <p v-if="displayCount">
      {{ foundPeople.length }} people found
    </p>
    <div>
      <div class="horizontal-left-content">
        <autocomplete
          class="full_width"
          url="/people/autocomplete"
          param="term"
          label="label_html"
          placeholder="Search a person..."
          clear-after
          @get-item="addToList"
        />
        <default-pin
          type="Person"
          section="People"
          @get-item="addToList"
        />
      </div>
      <table class="full_width">
        <thead>
          <tr>
            <th />
            <th>Cached</th>
            <th>Lived</th>
            <th>Active</th>
            <th>Used</th>
            <th>Roles</th>
          </tr>
        </thead>
        <tbody>
          <template
            v-for="person in foundPeople"
            :key="person.id"
          >
            <tr>
              <td>
                <button
                  type="button"
                  class="button normal-input button-default"
                  :disabled="person.id === selectedPerson['id']"
                  @click="selectedPerson = person"
                >
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
                <span class="feedback feedback-thin feedback-primary">{{ person.roles ? person.roles.length : 0 }}</span>
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

import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import { MutationNames } from '../store/mutations/mutations'
import Autocomplete from 'components/ui/Autocomplete.vue'
import DefaultPin from 'components/getDefaultPin.vue'
import getRoles from '../utils/getRoles'

export default {
  components: {
    Autocomplete,
    DefaultPin
  },

  props: {
    displayCount: {
      type: Boolean,
      default: false
    }
  },

  computed: {
    selectedPerson: {
      get () {
        return this.$store.getters[GetterNames.GetSelectedPerson]
      },

      set (value) {
        this.$store.commit(MutationNames.SetSelectedPerson, value)
      }
    },

    foundPeople () {
      return this.$store.getters[GetterNames.GetFoundPeopleList]
    }
  },

  methods: {
    addToList (person) {
      this.$store.dispatch(ActionNames.AddSelectPerson, person.id)
    },

    yearValue (value) {
      return value || '?'
    },

    getRoles
  }
}
</script>
