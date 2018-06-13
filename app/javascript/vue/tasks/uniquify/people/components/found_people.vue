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
            @click="selectName(key)">
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
      value: {
        type: Array,
        required: true
      }
    },
    data() {
      return {
        foundPeople: [],
        selectedPerson: {}
      }
    },
    methods: {
      SelectPerson() {
        this.selectedPerson = this.foundPeople[value]
      }
    }
  }
</script>
