<template>
  <div>
    <ul class="no_bullets">
      <li
          v-for="(label, key) in matchPeople"
          :key=label >
        <button
            type="button"
            @click="selectName(key)">
          {{ label }}
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
      },
      selectedPerson: {
        type: Object,
        required: true
      }
    },
    watch: {

    },
    data() {
      return {
        matchPeople: [],
        selectedPeople: []
      }
    },
    methods: {
      selectPerson(person) {
        if (this.selectedPeople.hasOwnProperty(person.id)) {
          this.$delete(this.selectedPeople, person.id)
        }
        else {
          this.$set(this.selectedPeople, person.id, person);
        }
        this.$emit('input', this.selectedPeople);
      }
    }
  }
</script>