<template>
  <form class="panel basic-information">
  <a class="anchor" name="status"></a>
    <div class="header flex-separate middle" :class="{ 'validation-warning' : softValidation.taxonStatusList.list.length }">
      <h3>Status</h3>
      <expand @changed="expanded = !expanded" :expanded="expanded"></expand>
    </div>
    <div class="body" v-if="expanded">
      <tree-display 
          v-if="taxon.id"
          :tree-list="treeList"
          :objectLists="objectLists"
          :parent="parent"
          :showModal="showModal"
          mutation-name-add="AddTaxonStatus" 
          mutation-name-modal="SetModalStatus"
          name-module="Status"
          display-name="name">
      </tree-display>
      <button class="normal-input" type="button" @click="showAdvance = false">Common</button>
      <button class="normal-input" @click="showAdvance = true" type="button">Advanced</button>
      <button class="normal-input" @click="activeModal(true)" type="button">Show all</button>
      <div class="separate-top">
        <autocomplete v-if="showAdvance"
          :arrayList="objectLists.allList"
          label="name"
          min="3"
          time="0"
          placeholder="Search"
          eventSend="autocompleteStatusSelected"
          param="term">
        </autocomplete>    
        <list-common :filter="true" :object-lists="objectLists" display="name" @addEntry="addEntry" :list-created="getStatusCreated"></list-common>
      </div>
      <list-entrys mutationNameRemove="RemoveTaxonStatus" :list="getStatusCreated" display="object_tag"></list-entrys>
    </div>
  </form>
</template>

<script>
  const ActionNames = require('../store/actions/actions').ActionNames;  
  const GetterNames = require('../store/getters/getters').GetterNames;
  const treeDisplay = require('./treeDisplay.vue');
  const listEntrys = require('./listEntrys.vue');
  const listCommon = require('./commonList.vue');
  const expand = require('./expand.vue');

  export default {
    components: {
      listEntrys,
      expand,
      treeDisplay,
      listCommon
    },
    computed: {
      treeList() {
        return this.$store.getters[GetterNames.GetStatusList]
      },
      parent() {
        return this.$store.getters[GetterNames.GetParent]
      },
      taxon() {
        return this.$store.getters[GetterNames.GetTaxon]
      },
      nomenclaturalCode() {
        return this.$store.getters[GetterNames.GetNomenclaturalCode]
      },
      showModal() {
        return this.$store.getters[GetterNames.ActiveModalStatus]
      },
      softValidation() {
        return this.$store.getters[GetterNames.GetSoftValidation]
      },
      getStatusCreated() {
        return this.$store.getters[GetterNames.GetTaxonStatusList]
      }
    },
    data: function() {
      return { 
        objectLists: this.makeLists(),
        expanded: true,
        showAdvance: false,
      }
    },
    watch: {
      parent: {
        handler: function(newVal) {
          if(newVal == null) return true
          this.refresh();
        },
        immediate: true
      }
    },
    methods: {
      makeLists: function() {
        return {
          tree: undefined,
          commonList: [],
          allList: [],
        }
      },
      addEntry: function(item) {
        console.log(item);
        this.$store.dispatch(ActionNames.AddTaxonStatus, item);
      },
      refresh: function() {
          let copyList = Object.assign({},this.treeList[this.nomenclaturalCode]);
          
          this.objectLists = Object.assign({}, this.makeLists());
          this.objectLists.tree = Object.assign({}, copyList.tree);
          
          this.getStatusListForThisRank(copyList.all,this.parent.rank_string).then( resolve => {
            this.objectLists.allList = resolve;
            this.getTreeListForThisRank(this.objectLists.tree, copyList.all, resolve);
          });
          this.getStatusListForThisRank(copyList.common,this.parent.rank_string).then( resolve => {
            this.objectLists.commonList = resolve;
          });
      },
      getStatusListForThisRank(list, findStatus) {
        return new Promise(function (resolve, reject) {
          var 
          newList = [];
          for (var key in list) {
            var t = list[key].applicable_ranks;
            t.find(function (item) {
              if(item == findStatus) {
                newList.push(list[key]);
                return true
              }
            });
          };
        resolve(newList);
        });
      },
      getTreeListForThisRank(list, ranksList, filteredList) {
        for(var key in list) {
            Object.defineProperty(list[key], 'name', { value: ranksList[key].name });
            Object.defineProperty(list[key], 'type', { value: ranksList[key].type });

            if(filteredList.find(function(item) {
              if(item.type == key) {
                return true;
              }
            })) {
              Object.defineProperty(list[key], 'disabled', { value: false, configurable: true });
            }
            else {
              Object.defineProperty(list[key], 'disabled', { value: true, configurable: true });
            }
            this.getTreeListForThisRank(list[key], ranksList, filteredList);
        }
      }      
    }
  }
</script>