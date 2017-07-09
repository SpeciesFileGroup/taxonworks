<template>
  <autocomplete
    url="/taxon_names/autocomplete"
    label="label_html"
    min="3"
    eventSend="parentSelected"
    display="label"
    :value="getParent.name"
    param="term">
  </autocomplete>
</template>

<script>
  const autocomplete = require('../../../components/autocomplete.vue');
  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;
  const ActionNames = require('../store/actions/actions').ActionNames;

  var foundRankGroup = require('../helpers/foundRankGroup');
  var truncateAtRank = require('../helpers/truncateAtRank');

  export default {
    components: {
      autocomplete
    },
    computed: {
      getParent: {
        get() {
          let value = this.$store.getters[GetterNames.GetParent];
          return (value != undefined ? value : '');
        }
      }
    },
    mounted: function() {
      var that = this;
      this.$on('parentSelected', function(item) {
       this.$store.commit(MutationNames.SetParentId, item.id);
       this.$http.get(`/taxon_names/${item.id}`).then( response => {
        this.$store.commit(MutationNames.SetRankClass, undefined);
        this.$store.commit(MutationNames.SetNomenclaturalCode, response.body.nomenclatural_code);
        this.$store.dispatch(ActionNames.SetParentAndRanks, response.body.parent);
      });
     });
    },
  };
</script>