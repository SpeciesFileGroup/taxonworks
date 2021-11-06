<template>
  <div
    v-if="items.length"
    class="slide-panel-category">
    <div class="slide-panel-category-header">Source</div>
    <ul class="slide-panel-category-content">
      <li
        v-for="item in items"
        @click="setSource(item)"
        class="flex-separate middle slide-panel-category-item">
        <span v-html="item.source.cached"/>
      </li>
    </ul>
  </div>
</template>

<script>

import { MutationNames } from '../store/mutations/mutations'
import { Citation, Source } from 'routes/endpoints'

export default {
  computed: {
    items () {
      return this.$store.getters.getOtuCitationsList
    }
  },
  methods: {
    removeCitation: function (item) {
      Citation.destroy(item.id).then(() => {
        this.$store.commit(MutationNames.RemoveOtuFormCitationList, item.id)
        this.$store.commit(MutationNames.RemoveSourceFormCitationList, item.id)
      })
    },
    setSource(item) {
      Source.find(item.source.id).then(response => {
        this.$store.commit(MutationNames.SetSourceSelected, response.body)
      })
    }
  }
}
</script>
