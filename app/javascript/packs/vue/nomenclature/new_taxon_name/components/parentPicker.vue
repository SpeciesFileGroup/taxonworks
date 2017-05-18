<template>
  <autocomplete
    url="/taxon_names/autocomplete"
    label="label_html"
    min="3"
    eventSend="parentSelected"
    display="label"
    param="term">
  </autocomplete>
</template>

<script>
  const autocomplete = require('../../../components/autocomplete.vue');
  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;

  var foundRankGroup = require('../helpers/foundRankGroup');
  var truncateAtRank = require('../helpers/truncateAtRank');

  export default {
    components: {
      autocomplete
    },
    mounted: function() {
      var that = this;
      this.$on('parentSelected', function(item) {
       this.$store.commit('setParentId', item.id);
       this.$http.get(`/taxon_names/${item.id}`).then( response => {
        var nomenclatureRanks = JSON.parse(JSON.stringify(that.$store.getters[GetterNames.GetRankList][response.body.nomenclatural_code]));
        var group = foundRankGroup(nomenclatureRanks, response.body.rank);
        response.body.rankGroup = group;
        nomenclatureRanks[group] = truncateAtRank(nomenclatureRanks[group], response.body.rank);
        that.$store.commit(MutationNames.SetParent, response.body);
        that.$store.commit(MutationNames.SetAllRanks, nomenclatureRanks);
      });
     });
    },
  };
</script>