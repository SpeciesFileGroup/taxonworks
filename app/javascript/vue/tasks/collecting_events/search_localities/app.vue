<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter collecting events</h1>
      <ul class="context-menu">
        <li>
          <label>
            <input
              type="checkbox"
              v-model="jsonBar">
            Show JSON Request
          </label>
        </li>
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
              v-shortkey="[getMacKey, 'f']"
              @shortkey="showFilter = !showFilter"
              v-model="showFilter">
            Show filter
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-shortkey="[getMacKey, 'm']"
              @shortkey="showMap = !showMap"
              v-model="showMap">
            Show map
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-shortkey="[getMacKey, 'l']"
              @shortkey="showList = !showList"
              v-model="showList">
            Show list
          </label>
        </li>
        <li>
          <span
            data-icon="reset"
            class="cursor-pointer"
            @click="resetApp">
            Reset
          </span>
        </li>
      </ul>
    </div>
    <header-bar
      v-if="jsonBar"
      :jsonUrl="jsonUrl"/>
    <collecting-event
      ref="ce"
      :show-result-map="showMap"
      :show-result-list="showList"
      :show-filter="showFilter"
      :append="append"
      @jsonUrl="jsonUrl = $event"
      @itemid="selectedItem=$event"
    />
  </div>
</template>
<script>

  import GetMacKey from 'helpers/getMacKey.js'
  import CollectingEvent from './components/collectingEvent.vue'
  import HeaderBar from './components/headerBar'

  export default {
    components: {
      CollectingEvent,
      HeaderBar
    },
    computed: {
      getMacKey() {
        return GetMacKey()
      }
    },
    data() {
      return {
        append: false,
        showMap: false,
        showList: true,
        showFilter: true,
        jsonBar: false,
        jsonUrl: ''
      }
    },
    methods: {
      resetApp() {
        this.$refs.ce.resetPage()
      }
    }
  }
</script>
