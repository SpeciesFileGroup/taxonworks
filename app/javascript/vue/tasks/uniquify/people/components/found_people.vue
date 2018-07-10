<template>
  <div>
    <ul class="no_bullets">
      <li v-for="person in foundPeople">
        <label>
          <input
            name="found-people"
            type="radio"
            v-model="selected"
            :value="person.id"
            @click="selectPerson(person)">
          {{ person.cached }}
        </label>
      </li>
    </ul>
  </div>

</template>
<script>
  // this is a list for selecting one person from potential selectees
  // only one person can be selected
  export default {
    props: {
      value: {
        type: Object,
        required: true
      },
      foundPeople: {
        type: Array,
        default: () => { return [] }
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
      selectPerson(person) {
        this.$http.get('/people/' + person.id.toString() + '.json').then(response => {
          this.selectedPerson = response.body;
          this.$emit('input', this.selectedPerson);
        })
        // console.log(person);
        // console.log(JSON.stringify(person, null, 2))
      },
      clearSelectedPerson() {
        this.selectedPerson = {};
      },
      // catchHttpStatus(status) {
      //   console.log(status);
      //   alert(status);
      // }
    }
  }
</script>
