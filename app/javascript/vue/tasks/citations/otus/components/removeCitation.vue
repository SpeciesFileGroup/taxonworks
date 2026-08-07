<template>
  <div
    class="circle-button circle-button-big btn-delete"
    v-if="citation"
    @click="removeCitation(citation)"
  />
</template>

<script setup>
import { Citation } from '@/routes/endpoints'
import useStore from '../store/store.js'
import { computed } from 'vue'

const store = useStore()

const citation = computed(() => store.selected.citation)

function removeCitation() {}
/* 
export default {
  computed: {
    citation() {
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
} */
</script>
