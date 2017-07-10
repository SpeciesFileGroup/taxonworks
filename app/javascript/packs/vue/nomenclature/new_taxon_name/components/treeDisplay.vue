<template>
  <form>
    <modal v-if="showModal" @close="activeModal(false)">
      <h3 slot="header">{{ nameModule }}</h3>
      <div slot="body" class="tree-list">
        <recursive-list :display="displayName" :modal-mutation-name="mutationNameModal" :action-mutation-name="mutationNameAdd" :objectList="objectLists.tree"></recursive-list>
      </div>
    </modal>
    <button class="normal-input" type="button" @click="showAdvance = false">Common</button>
    <button class="normal-input" @click="showAdvance = true" type="button">Advanced</button>
    <button class="normal-input" @click="activeModal(true)" type="button">Show all</button>
    <div class="separate-top">
      <autocomplete v-if="showAdvance"
        :arrayList="objectLists.allList"
        :label="displayName"
        min="3"
        time="0"
        placeholder="Search"
        eventSend="autocompleteStatusSelected"
        param="term">
      </autocomplete>    
      <div v-else class="flex-wrap-row">
        <ul class="flex-wrap-column no_bullets">
          <li class="status-item" v-for="item in objectLists.commonList">
            <label><input type="radio" name="status-item" @click="addEntry(item)" :value="item.type"/>{{ item[displayName] }}</label>
          </li>
        </ul>
      </div>
    </div>
  </form>
</template>
<script>

  const ActionNames = require('../store/actions/actions').ActionNames;  
  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;  
  const autocomplete = require('../../../components/autocomplete.vue');
  const recursiveList = require('./recursiveList.vue');
  const listEntrys = require('./listEntrys.vue');
  const modal = require('../../../components/modal.vue');


  export default {
    components: {
      autocomplete,
      recursiveList,
      listEntrys,
      modal
    },
    name: 'tree-display',
    props: ['treeList', 'parent', 'showModal','mutationNameAdd','mutationNameModal', 'objectLists', 'displayName', 'nameModule'],
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
      },
      addEntry: function(item) {
        this.$store.dispatch(ActionNames.AddTaxonStatus, item);
      },
    }
  };
</script>