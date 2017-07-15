<template>
  <form class="panel basic-information">
  <a class="anchor" name="status"></a>
    <div class="header flex-separate middle" :class="{ 'validation-warning' : softValidation.taxonStatusList.list.length }">
      <h3>Status</h3>
      <expand @changed="expanded = !expanded" :expanded="expanded"></expand>
    </div>
    <div class="body" v-if="expanded">
      <tree-display 
          :tree-list="treeList" 
          :objectLists="objectLists" 
          :parent="parent" 
          :showModal="showModal" 
          mutation-name-add="AddTaxonStatus" 
          mutation-name-modal="SetModalStatus"
          name-module="Status"
          display-name="name">
      </tree-display>
      <list-entrys mutationNameRemove="RemoveTaxonStatus" list="GetTaxonStatusList" display="object_tag"></list-entrys>
    </div>
    
  </form>
</template>

<script>

  const GetterNames = require('../store/getters/getters').GetterNames;
  const treeDisplay = require('./treeDisplay.vue');
  const listEntrys = require('./listEntrys.vue');
  const expand = require('./expand.vue');

  export default {
    components: {
      listEntrys,
      expand,
      treeDisplay
    },
    computed: {
      treeList() {
        return this.$store.getters[GetterNames.GetStatusList]
      },
      parent() {
        return this.$store.getters[GetterNames.GetParent]
      },
      nomenclaturalCode() {
        return this.$store.getters[GetterNames.GetNomenclaturalCode]
      },
      showModal() {
        return this.$store.getters[GetterNames.ActiveModalStatus]
      },
      softValidation() {
        return this.$store.getters[GetterNames.GetSoftValidation]
      }
    },
    data: function() {
      return { 
        objectLists: this.makeLists(),
        expanded: true
      }
    },
    watch: {
      parent: function(newVal, oldVal) {
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