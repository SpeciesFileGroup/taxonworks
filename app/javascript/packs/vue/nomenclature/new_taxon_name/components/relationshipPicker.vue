<template>
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
        return this.$store.getters[GetterNames.GetRelationshipList]
      },
      parent() {
        return this.$store.getters[GetterNames.GetParent]
      },
      showModal() {
        return this.$store.getters[GetterNames.ActiveModalRelationship]
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
        this.objectLists.commonList = Object.assign({}, this.treeList[this.parent.nomenclatural_code].common);
        this.objectLists.allList = Object.assign({}, this.treeList[this.parent.nomenclatural_code].all);
        this.objectLists.allList = Object.keys(this.objectLists.allList).map(key => this.objectLists.allList[key])
        this.getTreeList(this.objectLists.tree, this.treeList[this.parent.nomenclatural_code].all);
        this.addType(this.objectLists.commonList);
      }
    },
    methods: {
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