<template>
  <div>
    <pre>{{ selectedPerson }}</pre>
  </div>
</template>
<script>
  // this component receives and displays the selected person from foundPeople
  export default {
    props: {
      selectedPerson: {
        type: Object,
        default: function() {return {}}
        // required: true
      }
    },
    // watch: {
    //   selectedPerson
    // }
    data() {
      return {
        thisPerson: {}    // totally a dummy entry
      }
    }
  }
</script>