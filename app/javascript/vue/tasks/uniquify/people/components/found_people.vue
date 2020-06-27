<template>
  <div>
    <autocomplete
      url="/people/autocomplete"
      min="2"
      label="label_html"
      placeholder="Find another person"
      display="label"
      @getItem="addToList($event)"
      param="term"/>
    <p v-if="displayCount">{{ foundPeople.length }}  people found</p>
    <div>
      <ul class="no_bullets">
        <li
          v-for="person in foundPeople">
          <label>
            <input
              name="found-people"
              type="radio"
              :value="person.id"
              :checked="person.id == selected['id']"
              @click="selectPerson(person)">
            <span v-html="person.label_html"/>
          </label>
        </li>
      </ul>
    </div>
  </div>
</template>
<script>
  // this is a list for selecting one person from potential selectees
  // only one person can be selected
  import Autocomplete from 'components/autocomplete.vue'
  import AjaxCall from 'helpers/ajaxCall'

  export default {
    components: {
      Autocomplete
    },
    props: {
      value: {
        type: Object,
        required: true
      },
      foundPeople: {
        type: Array,
        default: () => { return [] }
      },
      displayCount: {
        type: Boolean,
        default: false
      }
    },
    data() {
      return {
        selectedPerson: {},
        selected: {}      // gets populated by the v-model to the value attribute of the radio button input 

      }
    },
    methods: {
      removeFromList(personID) {
        let index = this.foundPeople.findIndex(item => {
          return item.id == personID
        });

        if (index > -1)
          this.foundPeople.splice(index, 1)

      },  
      addToList(person) {
        this.selectPerson(person)
        person['cached'] = person.label
        this.$emit('addToList', person)
        this.selected = person
      },
      selectPerson(person) {
        AjaxCall('get', `/people/${person.id.toString()}.json`).then(response => {
          this.selectedPerson = response.body;
          this.$emit('input', this.selectedPerson);
        })
      },
      clearSelectedPerson() {
        this.selectedPerson = {};
        this.selected = {};
      },

    }
  }
</script>

