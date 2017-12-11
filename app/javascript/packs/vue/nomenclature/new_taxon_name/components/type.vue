<template>
  <form class="panel basic-information">
    <a name="type" class="anchor"></a>
    <div class="header flex-separate middle" :class="{ 'validation-warning' : softValidation.taxonRelationshipList.list.length }">
      <h3 class="">Type</h3>
      <expand @changed="expanded = !expanded" :expanded="expanded"></expand>
    </div>
    <div class="body" v-if="expanded">
      <div v-if="!taxonRelation">
        <hard-validation field="type" v-if="!(GetRelationshipsCreated.length)">
          <autocomplete slot="body"
              url="/taxon_names/autocomplete"
              label="label_html"
              display="label"
              min="3"
              eventSend="autocompleteType"
              @getItem="addTaxonType"
              placeholder="Search taxon name for the new relationship..."
              :addParams="{ type: 'Protonym', 'nomenclature_group[]': childOfParent[getRankGroup.toLowerCase()] }"
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
          mutation-name-add="AddTaxonType" 
          mutation-name-modal="SetModalType"
          name-module="Types"
          display-name="subject_status_tag">
        </tree-display>
        <div class="switch-radio">
          <input name="type-picker-options" id="type-picker-common" checked type="radio" class="normal-input button-active" @click="showAdvance = false"/>
          <label for="type-picker-common">Common</label>
          <input name="type-picker-options" id="type-picker-showall" type="radio" class="normal-input" @click="activeModal(true)"/>
          <label for="type-picker-showall">Show all</label>
        </div>
        <p class="inline">
          <span v-html="taxonRelation.label_html"></span>
          <span type="button" title="Remove" class="circle-button btn-undo" @click="taxonRelation = undefined"></span>
        </p>
        <div class="separate-top">
          <list-common :object-lists="objectLists.common" :filter="true" @addEntry="addEntry" display="subject_status_tag" :list-created="GetRelationshipsCreated"></list-common>
        </div>
      </div>
      <list-entrys @update="loadTaxonRelationships" @addCitation="setType" :list="GetRelationshipsCreated" @delete="removeType" :display="['object_status_tag', { link: '/tasks/nomenclature/browse/', label: 'subject_object_tag', param: 'subject_taxon_name_id'}]"></list-entrys>
    </div>
  </form>
</template>
<script>

  const ActionNames = require('../store/actions/actions').ActionNames;
  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;
  const treeDisplay = require('./treeDisplay.vue').default;
  const listEntrys = require('./listEntrys.vue').default;
  const listCommon = require('./commonList.vue').default;
  const expand = require('./expand.vue').default;
  const autocomplete = require('../../../components/autocomplete.vue').default;
  const hardValidation = require('./hardValidation.vue').default;
  const getRankGroup = require('../helpers/getRankGroup');
  const childOfParent = require('../helpers/childOfParent');

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
      getRankGroup() {
        return getRankGroup(this.$store.getters[GetterNames.GetTaxon].rank_string);
      },
      taxon() {
        return this.$store.getters[GetterNames.GetTaxon];
      },
      GetRelationshipsCreated() {
        var type = []
        type = this.$store.getters[GetterNames.GetTaxonRelationshipList].filter(function(item) { 
          return (item.type.split('::')[1] == 'Typification')
        });
        if(!type.length) {
          if(this.taxon.hasOwnProperty('type_taxon_name_relationship') && this.taxon['type_taxon_name_relationship']) {
            type.push(this.taxon.type_taxon_name_relationship);
            return type
          }
        }
        return type;
      },
      parent() {
        return this.$store.getters[GetterNames.GetParent]
      },
      softValidation() {
        return this.$store.getters[GetterNames.GetSoftValidation]
      },
      taxonRelation: {
        get() {
          return this.$store.getters[GetterNames.GetTaxonType]
        },
        set(value) {
          this.$store.commit(MutationNames.SetTaxonType, value);
        }
      },
      nomenclaturalCode() {
        return this.$store.getters[GetterNames.GetNomenclaturalCode]
      },
      showModal() {
        return this.$store.getters[GetterNames.ActiveModalType]
      }
    },
    data: function() {
      return { 
        objectLists: this.makeLists(),
        expanded: true,
        showAdvance: false,
        childOfParent: childOfParent,
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
      loadTaxonRelationships: function() {
        this.$store.dispatch(ActionNames.LoadTaxonRelationships, this.taxon.id)
      },
      setType(item) {
        this.$store.dispatch(ActionNames.UpdateTaxonRelationship, item);
      },
      removeType: function(item) {
        let taxon_name = Object.assign({}, this.$store.getters[GetterNames.GetTaxon])

        taxon_name['type_taxon_name_relationship'] = undefined;
        this.$store.dispatch(ActionNames.RemoveTaxonRelationship, item);
        this.$store.commit(MutationNames.SetTaxon, taxon_name);        
      },
      refresh: function() {
        this.objectLists.tree = this.filterList(this.addType(Object.assign({},this.treeList.typification.all)),this.getRankGroup);
        this.objectLists.common = this.filterList(this.addType(Object.assign({},this.treeList.typification.common)),this.getRankGroup);
      },
      activeModal: function(value) {
        this.$store.commit(MutationNames.SetModalType, value)
      },
      makeLists: function() {
        return {
          tree: undefined,
          common: undefined
        }
      },
      addTaxonType: function(taxon) {
      	this.taxonRelation = taxon;
      	if(this.getRankGroup == 'Family')
      		this.addEntry(this.objectLists.tree[Object.keys(this.objectLists.tree)[0]]);
      },
      addEntry: function(item) {
        this.$store.dispatch(ActionNames.AddTaxonType, item);
      },
      filterList: function(list, filter) {
      	let tmp = {};

      	for(var key in list) {
      		if(key.split('::')[2] == filter)
      			tmp[key] = list[key]
      	}
      	return tmp;
      },
      addType(list) {
        for(var key in list) {
          Object.defineProperty(list[key], 'type', { value: key });
        }
        return list;
      }
    }
  }
</script>