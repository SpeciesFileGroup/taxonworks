<template>
  <div>
    <span>{{ mergePerson }}</span>
  </div>
</template>
<script>
  // this component receives and displays the selected person from foundPeople
  export default {
    props: {
      mergePerson: {
        type: Object,
        default: function() {return {}}
        // required: true
      },
      // value: {
      //   type: Array,
      //   default: []
      // }
    },
    watch: {
      mergePerson(newVal) {
        mergePerson = newVal
      }
    },
    data() {
      return {
        thisPerson: {}    // totally a dummy entry
      }
    }
  }
</script>