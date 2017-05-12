<template>
  <div class="circle-button circle-button-big btn-delete" v-if="citation" @click="removeCitation(citation)"></div>
</template>

<script>
  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;

  export default {
    computed: {
      citation() {
        return this.$store.getters[GetterNames.GetCitationSelected]
      }
    },
    methods: {
      removeCitation: function(item) { 

        this.$http.delete("/citations/" + item.id).then(response => {
          this.$store.commit(MutationNames.RemoveSourceFormCitationList, item.id);
          this.$store.commit(MutationNames.RemoveCitationSelected);
          this.$store.commit(MutationNames.SetOtuCitationsList, []);
        });
      }
    }                
  };
</script>