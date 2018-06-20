<template>
  <div>
    <pre>{{ mergePerson }}</pre>
  </div>
</template>
<script>
  // this component receives and displays the selected person from foundPeople
  export default {
    props: {
      mergePerson: {
        type: Object,
        default: function () {
          return {}
        }
        // required: true
      },
    },
    data() {
      return {
        thisPerson: {}    // totally a dummy entry
      }
    }
  }
</script>