<template>
  <div>
    <spinner-component
      :show-legend="false"
      v-if="isSearching"/>
    <template
      v-if="foundMatches">
      <ul
        v-for="item in matches"
        :key="item.id"
        class="no_bullets">
        <li
          class="margin-small-top">
          <button
            class="button normal-input button-submit full_width"
            type="button"
            @click="send({ otuName: undefined, taxon: item })">
            Create and use OTU for taxon name <span v-html="item.cached_html"/>
          </button>
        </li>
        <li
          class="margin-small-top">
          <button
            class="button normal-input button-submit full_width"
            type="button"
            @click="send({ otuName: item.cached, taxon: item })">
            Create and use OTU with name "<span v-html="item.cached_html"/>"
          </button>
        </li>
        <li class="margin-small-top">
          <button
            @click="createNew"
            type="button"
            class="button normal-input button-default full_width">
            Customize a new OTU with name "{{ otuName }}"
          </button>
        </li>
      </ul>
    </template>
    <ul
      class="no_bullets"
      v-else>
      <li class="margin-small-top">
        <button
          @click="createNew"
          type="button"
          class="button normal-input button-default full_width">
          Customize a new OTU with name "{{ otuName }}"
        </button>
      </li>
    </ul>
  </div>
</template>

<script>

import SpinnerComponent from 'components/spinner'
import { TaxonName } from 'routes/endpoints'

export default {
  components: { SpinnerComponent },

  props: {
    otuName: {
      type: String,
      default: undefined
    }
  },

  emits: [
    'selected',
    'createNew'
  ],

  data () {
    return {
      matches: [],
      delay: 1000,
      timeOut: undefined,
      isSearching: false,
      searchDone: false
    }
  },

  watch: {
    otuName: {
      handler (newVal) {
        this.isSearching = true
        this.foundMatches = false

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
      TaxonName.where({
        name: this.otuName,
        exact: true
      }).then(response => {
        this.matches = response.body
        this.isSearching = false
        this.foundMatches = response.body.length > 0
      })
    },

    send (taxon) {
      this.$emit('selected', taxon)
    },

    createNew () {
      this.$emit('createNew', true)
    }
  }
}
</script>
