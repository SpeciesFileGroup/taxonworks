<template>
  <div>
    <pre>{{ mergePerson }}</pre><br><br>{{ mergePerson.length }}
  </div>
</template>
<script>
  // this component receives and displays the selected person from matchPeople
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