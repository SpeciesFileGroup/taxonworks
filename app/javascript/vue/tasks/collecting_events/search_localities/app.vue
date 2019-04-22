<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter collecting events</h1>
      <ul class="context-menu">
        <li>
          <label>
            <input
              type="checkbox"
              v-model="append">
            Append results
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="showMap">
            Show map
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="showList">
            Show list
          </label>
        </li>
        <li>
          <span
            data-icon="reset"
            class="cursor-pointer">
            Reset
          </span>
        </li>
      </ul>
    </div>
    <collecting-event
      ref="ce"
      :show-result-map="showMap"
      :show-result-list="showList"
      @itemid="selectedItem=$event"
    />
  </div>
</template>
<script>

  import CollectingEvent from './components/collectingEvent.vue'

  export default {
    components: {
      CollectingEvent,
    },
    data() {
      return {
        append: false,
        showMap: false,
        showList: true
      }
    },
    methods: {
      resetApp() {
        this.$refs.ce.resetPage()
      }
    }
  }
</script>
