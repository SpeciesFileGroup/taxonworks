<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter collecting events</h1>
      <span
        data-icon="reset"
        class="cursor-pointer">
        Reset
      </span>
    </div>
    <collecting-event
      ref="ce"
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
    methods: {
      resetApp() {
        this.$refs.ce.resetPage()
      }
    }
  }
</script>
