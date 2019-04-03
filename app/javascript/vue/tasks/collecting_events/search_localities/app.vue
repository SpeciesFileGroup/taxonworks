<template>
  <div>
    <h1>Search and List Localities</h1>
    <collecting-event
      @itemid="selectedItem=$event"
    />
  </div>
</template>
<script>
  import CollectingEvent from './components/collectingEvent.vue'
// TODO: ? (de)/persist lists
  export default {
    components: {
      CollectingEvent,
    },
  }
</script>
