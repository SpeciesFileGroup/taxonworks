<template>
  <div>
    <ul class="no_bullets">
      <li v-for="(person, index) in foundPeople">
        <label>
          <input
            name="found-people"
            type="radio"
            :selected="person.id == value"
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
        selectedPerson: {}
      }
    },
    methods: {
      selectPerson(person) {
        this.selectedPerson = person;
        this.$emit('input', person)
      }
    }
  }
</script>
