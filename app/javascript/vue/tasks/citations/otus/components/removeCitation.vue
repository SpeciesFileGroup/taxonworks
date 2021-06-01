<template>
  <div
    class="circle-button circle-button-big btn-delete"
    v-if="citation"
    @click="removeCitation(citation)"/>
</template>

<script>
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { Citation } from 'routes/endpoints'

export default {
  computed: {
    citation () {
      return this.$store.getters[GetterNames.GetCitationSelected]
    }
  },

  methods: {
    removeCitation: function (item) {
      Citation.destroy(item.id).then(() => {
        this.$store.commit(MutationNames.RemoveSourceFormCitationList, item.id)
        this.$store.commit(MutationNames.RemoveCitationSelected)
        this.$store.commit(MutationNames.SetOtuCitationsList, [])
      })
    }
  }
}
</script>
