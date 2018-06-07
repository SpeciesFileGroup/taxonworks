<template>
  <div>
    <ul class="no_bullets">
      <li
          v-for="(label, key) in foundPeople"
          :key=label >
        <button
            type="button"
            :class="{ 'button-default': (key != value)}"
            class="button normal-input biocuration-toggle-button"
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
        type: Object,
        required: true
      }
    },
    data() {
      return {
        foundPeople: {},
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