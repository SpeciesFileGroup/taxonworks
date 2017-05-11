<template>
  <div v-if="items.length" class="slide-panel-category">
    <div class="slide-panel-category-header">Source</div>
    <ul class="slide-panel-category-content">
      <li v-for="item in items" class="flex-separate middle slide-panel-category-item"><span v-html="item.source.object_tag"></span><div class="circle-button btn-delete" @click="removeCitation(item)"></div></li>
    </ul>
  </div>
</template>

<script>

  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;

  export default {
    computed: {
      items() {
        return this.$store.getters.getOtuCitationsList
      },     
    },
    methods: {
      removeCitation: function(item) { 
        this.$http.delete("/citations/" + item.id).then(response => {
          this.$store.commit(MutationNames.RemoveOtuFormCitationList, item.id);
          this.$store.commit(MutationNames.RemoveSourceFormCitationList, item.id);
        });
      }
    }
  };
</script>