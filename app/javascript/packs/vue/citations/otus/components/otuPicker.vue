<template>
  <div>
    <div class="flex-wrap-row middle">
      <button class="button button-default normal-input" @click="showModal = true" v-if="otu">Change OTU</button>
      <button class="button button-default normal-input" @click="showModal = true" v-else>Select OTU</button>
    </div>
    <modal @close="showModal = false" v-if="showModal" @otupicker="loadOtu">
      <h3 slot="header">Select OTU</h3>
      <div slot="body">
        <autocomplete
        url="/otus/autocomplete"
        min="2"
        param="term"
        placeholder="Find OTU"
        event-send="otupicker"
        label="label"
        :autofocus="true">
      </autocomplete>
    </div>
  </modal>
</div>
</template>

<script>
  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;

  const autocomplete = require('../../../components/autocomplete.vue');
  const modal = require('../../../components/modal.vue');

  export default {
    data: function() {
      return {
        showModal: false
      }
    },
    components: {
      autocomplete,
      modal
    },
    computed: {
      otu() {
        return this.$store.getters[GetterNames.GetOtuSelected]
      }
    },
    methods: {
      loadOtu: function(item) {
        this.$http.get("/otus/" + item.id).then( response => {
          this.$store.commit(MutationNames.SetOtuSelected, response.body);
          this.showModal = false; 
        });
      }
    }
  };
</script>