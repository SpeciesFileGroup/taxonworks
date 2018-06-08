<template>
  <div>
    <ul class="no_bullets">
      <li
          v-for="(label, key) in matchPeople"
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
        matchPeople: {},
        selectedPeople: {}
      }
    },
    methods: {
      SelectPerson() {
        this.selectedPeople = this.matchPeople[value]
      }
    }
  }
</script>