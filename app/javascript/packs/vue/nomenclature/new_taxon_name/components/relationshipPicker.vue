<template>
  <form class="panel basic-information">
    <a name="relationship" class="anchor"></a>
    <div class="header flex-separate middle" :class="{ 'validation-warning' : softValidation.taxonRelationshipList.list.length }">
      <h3 class="">Relationship</h3>
      <expand @changed="expanded = !expanded" :expanded="expanded"></expand>
    </div>
    <div class="body" v-if="expanded">
      <div v-if="!taxonRelation">
        <hard-validation field="object_taxon_name_id">
          <autocomplete slot="body"
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
        </hard-validation>
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
          <list-common :object-lists="objectLists" @addEntry="addEntry" display="subject_status_tag" :list-created="GetRelationshipsCreated"></list-common>
        </div>
      </div>
      <list-entrys mutationNameRemove="RemoveTaxonRelationship" :list="GetRelationshipsCreated" display="object_tag"></list-entrys>
    </div>
  </form>
</template>
<script>

  const ActionNames = require('../store/actions/actions').ActionNames;
  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;
  const treeDisplay = require('./treeDisplay.vue');
  const listEntrys = require('./listEntrys.vue');
  const listCommon = require('./commonList.vue');
  const expand = require('./expand.vue');
  const autocomplete = require('../../../components/autocomplete.vue');
  const hardValidation = require('./hardValidation.vue');

  export default {
    components: {
      listEntrys,
      autocomplete,
      expand,
      treeDisplay,
      listCommon,
      hardValidation
    },
    computed: {
      treeList() {
        return this.$store.getters[GetterNames.GetRelationshipList]
      },
      GetRelationshipsCreated() {
        return this.$store.getters[GetterNames.GetTaxonRelationshipList]
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
      activeModal: function(value) {
        this.$store.commit(MutationNames.SetModalRelationship, value)
      },
      makeLists: function() {
        return {
          tree: undefined,
          commonList: [],
          allList: [],
        }
      },
      filterAlreadyPicked: function(list, type) {
        return list.find(function(item) {
          return (item.type == type)
        });
      },
      addEntry: function(item) {
        this.$store.dispatch(ActionNames.AddTaxonRelationship, item);
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