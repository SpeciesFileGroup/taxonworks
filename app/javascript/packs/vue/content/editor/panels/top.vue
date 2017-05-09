<template>
  <div v-if="display" id="otu_panel" class="panel content">
    <autocomplete
      url="/otus/autocomplete"
      min="3"
      param="term"
      placeholder="Find OTU"
      event-send="otu_picker"
      label="label">
    </autocomplete>
  </div>
</template>

<script>

  var autocomplete = require('../../../components/autocomplete.vue');
  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;

  export default {
    name: 'panel-top',
    computed: {
      display() {
        return this.$store.getters[GetterNames.ActiveOtuPanel];
      }
    },
    mounted: function() {
      var that = this;
      this.$on('otu_picker', function (item) {
        that.$http.get("/otus/" + item.id).then( response => {
          that.$store.commit(MutationNames.SetOtuSelected, response.body); 
        }) 
      })                  
    },
    components: {
      autocomplete
    }
  };
</script>