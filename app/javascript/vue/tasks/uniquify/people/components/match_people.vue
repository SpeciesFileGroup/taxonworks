<template>
  <div>
    <spinner-component
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <autocomplete
      url="/people/autocomplete"
      min="2"
      label="label_html"
      placeholder="Find another person"
      display="label"
      @getItem="addToList($event)"
      param="term"/>
    <p v-if="selectedPerson">{{ matchList.length }}  matches found</p>
    <div>
      <ul class="no_bullets list-search">
        <template v-for="person in matchList">
          <li :key="person.id">
            <label>
              <input
                name="match-people"
                type="radio"
                :checked="selectedPerson && person.id === selectedPerson['id']"
                :value="person.id"
                @click="selectMergePerson(person)">
              <span v-html="person.label_html"/>
            </label>
          </li>
        </template>
      </ul>
    </div>
  </div>
</template>
<script>
// this is a list for selecting one person from potential matchees
// only one person can be selected
import Autocomplete from 'components/autocomplete.vue'
import { GetPeople, GetPeopleSimilar } from '../request/resources'
import SpinnerComponent from 'components/spinner'

export default {
  components: {
    Autocomplete,
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
      mergePerson: {},
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
      GetPeopleSimilar(person.id).then(response => {
        this.isLoading = false
        this.matchPeople = response.body
      })
    }
  }
};
</script>

<style scoped>
.list-search {
  max-height: 500px;
  overflow-y: scroll;
}

</style>
