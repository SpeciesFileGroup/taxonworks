<template>
  <form v-if="parent">
    <modal class="taxon-modal" v-if="showModal" @close="activeModal(false)">
      <h3 slot="header">{{ nameModule }}</h3>
      <div slot="body" class="tree-list">
        <recursive-list :getter-list="getterList" :display="displayName" :modal-mutation-name="mutationNameModal" :action-mutation-name="mutationNameAdd" :objectList="objectLists.tree"></recursive-list>
      </div>
    </modal>
  </form>
</template>
<script>

  const ActionNames = require('../store/actions/actions').ActionNames;  
  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;  
  const autocomplete = require('../../../components/autocomplete.vue').default;
  const recursiveList = require('./recursiveList.vue').default;
  const listEntrys = require('./listEntrys.vue').default;
  const modal = require('../../../components/modal.vue').default;


  export default {
    components: {
      autocomplete,
      recursiveList,
      listEntrys,
      modal
    },
    name: 'tree-display',
    props: ['treeList', 'parent', 'showModal','mutationNameAdd','mutationNameModal', 'objectLists', 'displayName', 'nameModule', 'getterList'],
    data: function() {
      return {
        showAdvance: false,
      }
    },
    computed: {
      taxon() {
        return this.$store.getters[GetterNames.GetTaxon]
      }
    },
    mounted: function() {
      var that = this;
      this.$on('closeModal', function () {
        that.showModal = false;
      });
      this.$on('autocompleteStatusSelected', function (status) {
        that.addEntry(status);
      })
    },
    methods: {
      activeModal: function(value) {
        this.$store.commit(MutationNames[this.mutationNameModal], value)
      }
    }
  };
</script>