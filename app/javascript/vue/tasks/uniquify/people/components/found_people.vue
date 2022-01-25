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
      <div class="horizontal-left-content">
        <autocomplete
          class="full_width"
          url="/people/autocomplete"
          param="term"
          label="label_html"
          placeholder="Search a person..."
          clear-after
          @getItem="addToList"/>
        <default-pin
          type="Person"
          section="People"
          @getItem="addToList"/>
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
          <template v-if="expanded">
            <template
              v-for="person in foundPeople"
              :key="person.id">
              <tr>
                <td>
                  <button
                    v-if="person.id != selected['id']"
                    type="button"
                    class="button normal-input button-default"
                    @click="selectPerson(person)">
                    Select
                  </button>
                  <button
                    v-else
                    type="button"
                    class="button normal-input button-default"
                    disabled>
                    Selected
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
          </template>
          <tr v-else>
            <td>
              <button
                type="button"
                class="button normal-input button-default"
                disabled>
                Selected
              </button>
            </td>
            <td>{{ selected.cached }}</td>
            <td>
              <span class="feedback feedback-secondary feedback-thin line-nowrap">{{ yearValue(selected.year_born) }} - {{ yearValue(selected.year_died) }}</span>
            </td>
            <td>
              <span class="feedback feedback-secondary feedback-thin line-nowrap">{{ yearValue(selectedPerson.year_active_start) }} - {{ yearValue(selected.year_active_end) }}</span>
            </td>
            <td>
              <span class="feedback feedback-thin feedback-primary">{{ selected.roles ? selected.roles.length : selected.usedCount || '?' }}</span>
            </td>
            <td>{{ getRoles(selected) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
<script>

import Autocomplete from 'components/ui/Autocomplete.vue'
import DefaultPin from 'components/getDefaultPin.vue'
import { People } from 'routes/endpoints'

export default {
  components: {
    Autocomplete,
    DefaultPin
  },

  props: {
    modelValue: {
      type: Object,
      default: undefined
    },
    foundPeople: {
      type: Array,
      default: () => []
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

  emits: [
    'update:modelValue',
    'addToList',
    'expand'
  ],

  computed: {
    selectedPerson: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  data () {
    return {
      selected: {}
    }
  },

  methods: {
    removeFromList (personID) {
      const index = this.foundPeople.findIndex(item => item.id === personID)

      if (index > -1) {
        this.foundPeople.splice(index, 1)
      }
    },

    async addToList (person) {
      const personObj = await this.selectPerson(person)

      if (person?.label_html) {
        let element = document.createElement('span')
        element.innerHTML = person.label_html
        element = element.querySelector('[data-count]')
        personObj.usedCount = element?.getAttribute('data-count')
      }

      this.$emit('addToList', personObj)
      this.selected = personObj
    },

    async selectPerson (person) {
      this.selected = person
      return People.find(person.id, { extend: ['roles'] }).then(response => {
        this.selectedPerson = response.body
        this.$emit('expand', false)
        return response.body
      })
    },

    getRoles (person) {
      return person.roles ? [...new Set(person.roles.map(r => r.role_object_type))].join(', ') : '?'
    },

    yearValue (value) {
      return value || '?'
    }
  }
}
</script>
