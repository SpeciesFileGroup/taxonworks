<template>
  <div>
    <ul class="no_bullets">
      <li
          v-for="person in foundPeople"
           :key=person.id>
        <button
            type="button"
            :class="{ 'button-default': (key != person.id)}"
            class="button normal-input biocuration-toggle-button"
            @click="selectPerson(0)">
          {{ person.cached }}
        </button>
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
        required: true
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
