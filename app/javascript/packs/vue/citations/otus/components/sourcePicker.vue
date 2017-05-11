<template>
  <div>
    <div class="flex-wrap-row middle">
      <button class="button button-default normal-input" @click="showModal = true" v-if="source">Change source</button>
      <button class="button button-default normal-input" @click="showModal = true" v-else>Select source</button>
    </div>
    <modal @close="showModal = false" v-if="showModal" @sourcepicker="loadSource">
      <h3 slot="header">Select source</h3>
      <div slot="body" id="source_panel">
        <autocomplete
          url="/sources/autocomplete"
          min="2"
          param="term"
          placeholder="Find source"
          event-send="sourcepicker"
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
        source() {
          return this.$store.getters[GetterNames.GetSourceSelected]
        }
      },
      methods: {
        loadSource: function(item) {
          this.$http.get("/sources/" + item.id).then( response => {
            this.$store.commit(MutationNames.SetSourceSelected, response.body); 
            this.showModal = false;
          }); 
        }                 
      },
    };
</script>