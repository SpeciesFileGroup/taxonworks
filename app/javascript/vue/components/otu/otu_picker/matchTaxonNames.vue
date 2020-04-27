<template>
  <div>
    <spinner-component
      :show-legend="false"
      v-if="isSearching"/>
    <ul class="no_bullets">
      <li
        v-for="item in matches"
        class="horizontal-left-content">
        <span v-html="item.cached_html"/>
        <button
          class="button normal-input button-default margin-medium-left"
          type="button"
          @click="setTaxonName(item)">
          Select
        </button>
      </li>
    </ul>
  </div>
</template>

<script>

import ajaxCall from 'helpers/ajaxCall'
import SpinnerComponent from 'components/spinner'

export default {
  components: {
    SpinnerComponent
  },
  props: {
    otuName: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      matches: [],
      delay: 1000,
      timeOut: undefined,
      isSearching: false
    }
  },
  watch: {
    otuName: {
      handler (newVal) {
        this.isSearching = true
        clearTimeout(this.timeOut)
        this.timeOut = setTimeout(() => {
          this.searchByTaxonName()
        }, this.delay)
      },
      immediate: true
    }
  },
  methods: {
    searchByTaxonName () {
      ajaxCall('get', `/taxon_names.json?name=${this.otuName}&exact=true`).then(response => {
        this.matches = response.body
        this.isSearching = false
      })
    },
    setTaxonName (taxon) {
      this.$emit('selected', taxon)
    }
  }
}
</script>
