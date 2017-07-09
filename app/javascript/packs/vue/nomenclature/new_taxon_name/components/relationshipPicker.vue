<template>
  <div>
    <tree-display 
      :tree-list="treeList" 
      :parent="parent" 
      :objectLists="objectLists" 
      :showModal="showModal" 
      mutation-name-add="AddTaxonRelationship" 
      mutation-name-modal="SetModalRelationship"
      name-module="Relationship"
      display-name="subject_status_tag">
    </tree-display>
    <taxon-name-picker></taxon-name-picker>
  </div>
</template>
<script>

  const GetterNames = require('../store/getters/getters').GetterNames;
  const treeDisplay = require('./treeDisplay.vue');
  const taxonNamePicker = require('./taxonNamePicker.vue');

  export default {
    components: {
      taxonNamePicker,
      treeDisplay
    },
    computed: {
      treeList() {
        return this.$store.getters[GetterNames.GetRelationshipList]
      },
      parent() {
        return this.$store.getters[GetterNames.GetParent]
      },
      nomenclaturalCode() {
        return this.$store.getters[GetterNames.GetNomenclaturalCode]
      },
      showModal() {
        return this.$store.getters[GetterNames.ActiveModalRelationship]
      }
    },
    data: function() {
      return { 
        objectLists: this.makeLists()
      }
    },
    watch: {
      parent: function(newVal, oldVal) {
        let copyList = Object.assign({},this.treeList[this.nomenclaturalCode]);
        this.objectLists.tree = Object.assign({}, copyList.tree);
        this.objectLists.commonList = Object.assign({}, copyList.common);
        this.objectLists.allList = Object.assign({}, copyList.all);
        this.objectLists.allList = Object.keys(this.objectLists.allList).map(key => this.objectLists.allList[key])
        this.getTreeList(this.objectLists.tree, copyList.all);
        this.addType(this.objectLists.commonList);
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
      getTreeList(list, ranksList) {
        for(var key in list) {
            if(key in ranksList) {
              Object.defineProperty(list[key], 'type', { value: key });
              Object.defineProperty(list[key], 'object_status_tag', { value: ranksList[key].object_status_tag });
              Object.defineProperty(list[key], 'subject_status_tag', { value: ranksList[key].subject_status_tag });
            }
            this.getTreeList(list[key], ranksList);
        }
      },
      addType(list) {
        for(var key in list) {
          Object.defineProperty(list[key], 'type', { value: key });
        }
      }
    }
  }
</script>