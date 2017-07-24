<template>
  <form class="panel basic-information">
    <a name="relationship" class="anchor"></a>
    <div class="header flex-separate middle" :class="{ 'validation-warning' : softValidation.taxonRelationshipList.list.length }">
      <h3 class="">Relationship</h3>
      <expand @changed="expanded = !expanded" :expanded="expanded"></expand>
    </div>
    <div class="body" v-if="expanded">
      <div v-if="!taxonRelation">
        <autocomplete
            :class="{ field_with_errors : existError('object_taxon_name_id') }"
            url="/taxon_names/autocomplete"
            label="label_html"
            min="3"
            time="0"
            v-model="taxonRelation"
            eventSend="autocompleteTaxonRelationshipSelected"
            placeholder="Search taxon name for the new relationship..."
            :addParams="{ type: 'Protonym' }"
            param="term">
        </autocomplete>
        <div v-if="existError('object_taxon_name_id')">
          <span v-for="error in errors.object_taxon_name_id">{{ error }}</span>
        </div>
      </div>
      <div v-else>
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
      </div>
      <list-entrys mutationNameRemove="RemoveTaxonRelationship" list="GetTaxonRelationshipList" display="object_tag"></list-entrys>
    </div>
  </form>
</template>
<script>

  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;
  const treeDisplay = require('./treeDisplay.vue');
  const taxonNamePicker = require('./taxonNamePicker.vue');
  const listEntrys = require('./listEntrys.vue');
  const expand = require('./expand.vue');
  const autocomplete = require('../../../components/autocomplete.vue');

  export default {
    components: {
      taxonNamePicker,
      listEntrys,
      autocomplete,
      expand,
      treeDisplay
    },
    computed: {
      treeList() {
        return this.$store.getters[GetterNames.GetRelationshipList]
      },
      parent() {
        return this.$store.getters[GetterNames.GetParent]
      },
      errors() {
        return this.$store.getters[GetterNames.GetHardValidation]
      },
      softValidation() {
        return this.$store.getters[GetterNames.GetSoftValidation]
      },
      taxonRelation: {
        get() {
          return this.$store.getters[GetterNames.GetTaxonRelationship]
        },
        set(value) {
          this.$store.commit(MutationNames.SetTaxonRelationship, value);
        }
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
        objectLists: this.makeLists(),
        expanded: true,
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
      existError: function(type) {
        return (this.errors && this.errors.hasOwnProperty(type));
      },
      refresh: function() {
        let copyList = Object.assign({},this.treeList[this.nomenclaturalCode]);
        this.objectLists.tree = Object.assign({}, copyList.tree);
        this.objectLists.commonList = Object.assign({}, copyList.common);
        this.objectLists.allList = Object.assign({}, copyList.all);
        this.objectLists.allList = Object.keys(this.objectLists.allList).map(key => this.objectLists.allList[key])
        this.getTreeList(this.objectLists.tree, copyList.all);
        this.addType(this.objectLists.commonList);
      },
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