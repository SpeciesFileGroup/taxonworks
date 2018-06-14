<template>
  <div>
    <ul class="no_bullets">
      <li
          v-for="(person, index) in foundPeople"
      >
        <input
            name="found-people"
            type="radio"
            @click="selectPerson(index)">
          {{ person.cached }}
      </li>
    </ul>
  </div>

</template>
<script>
  // this is a list for selecting one person from potential selectees
  // only one person can be selected
  export default {
    props: {
      // value: {
      //   type: Array,
      //   required: true
      // },
      foundPeople: {
        type: Array,
        default: [],
        // required: true
      }
    },
    data() {
      return {
        selectedPerson: {}
      }
    },
    // watch: {
    //   value(newVal) {
    //     this.foundPeople = this.value
    //   }
    // },
    methods: {
      selectPerson(who) {
        this.selectedPerson = this.foundPeople[who]
      }
    }
  }
</script>
