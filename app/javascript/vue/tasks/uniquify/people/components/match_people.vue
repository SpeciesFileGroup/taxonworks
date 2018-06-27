<template>
  <div>
    <ul class="no_bullets">
      <li
          v-for="(person, index) in matchPeople">

        <label>
          <input
              name="match-people"
              type="radio"
              :selected="person.id == mergePerson['id']"
              @click="selectMergePerson(person)">
          {{ person.cached }}
        </label>
      </li>
    </ul>
  </div>

</template>
<script>
  // this is a list for selecting one person from potential matchees
  // only one person can be selected
  export default {
    props: {
      value: {
        type: Object,
        required: true
      },
      selectedPerson: {
        type: Object,
        required: true
      }
    },
    watch: {
      selectedPerson(newVal) {
        this.getMatchPeople(newVal)
      }
    },
    data() {
      return {
        // selectedPeople: {},
        matchPeople: [],
        mergePerson: {}
      }
    },
    methods: {
      removeFromList(personId) {
        let index = this.matchPeople.findIndex(item => {
          return item.id == personId
        });

        if (index > -1)
          this.matchPeople.splice(index, 1)
      },
      selectMergePerson(person) {
        this.mergePerson = person;
        this.$emit('input', this.mergePerson);
        console.log(this.mergePerson);
        console.log(JSON.stringify(this.mergePerson));
      },
      getMatchPeople(person) {
        this.mergePerson = {};
        if ((person.last_name == undefined) && (person.last_name == undefined)) {
          this.matchPeople = [];    // new search
          return false
        }
        let params = {
          lastname: person.last_name,
          firstname: person.first_name,
          roles: []
        };
        this.$http.get('/people.json', {params: params}).then(response => {
          this.matchPeople = response.body;
          this.removeFromList(person.id)
          console.log(this.matchPeople);
        })
      },
        clearMergePerson() {
          this.mergePerson = {}
        }
    }
  }
</script>