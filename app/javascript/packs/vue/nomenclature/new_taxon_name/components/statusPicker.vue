<template>
  <tree-display 
    :tree-list="treeList" 
    :objectLists="objectLists" 
    :parent="parent" 
    :showModal="showModal" 
    mutation-name-add="AddTaxonStatus" 
    mutation-name-modal="SetModalStatus"
    mutation-name-list="GetTaxonStatusList"
    mutation-name-remove="RemoveTaxonStatus"
    name-module="Status"
    display-name="name">
  </tree-display>
</template>

<script>

  const GetterNames = require('../store/getters/getters').GetterNames;
  const treeDisplay = require('./treeDisplay.vue');

  export default {
    components: {
      treeDisplay
    },
    computed: {
      treeList() {
        return this.$store.getters[GetterNames.GetStatusList]
      },
      parent() {
        return this.$store.getters[GetterNames.GetParent]
      },
      showModal() {
        return this.$store.getters[GetterNames.ActiveModalStatus]
      }
    },
    data: function() {
      return { 
        objectLists: {
          tree: undefined,
          commonList: [],
          allList: [],
        }
      }
    },
    watch: {
      'parent': function(newVal, oldVal) {
        this.objectLists.tree = Object.assign({}, this.treeList[this.parent.nomenclatural_code].tree);
        
        this.getStatusListForThisRank(this.treeList[this.parent.nomenclatural_code].all,this.parent.rank_string).then( resolve => {
          this.objectLists.allList = resolve;
          this.getTreeListForThisRank(this.objectLists.tree, this.treeList[this.parent.nomenclatural_code].all, resolve);
        });
        this.getStatusListForThisRank(this.treeList[this.parent.nomenclatural_code].common,this.parent.rank_string).then( resolve => {
          this.objectLists.commonList = resolve;
        });
      }
    },
    methods: {
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
              Object.defineProperty(list[key], 'disabled', { value: false });
            }
            else {
              Object.defineProperty(list[key], 'disabled', { value: true });
            }
            this.getTreeListForThisRank(list[key], ranksList, filteredList);
        }
      }      
    }
  }
</script>