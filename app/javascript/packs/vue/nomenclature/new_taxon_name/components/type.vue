<template>
  <form class="panel basic-information">
    <a name="relationship" class="anchor"></a>
    <div class="header flex-separate middle" :class="{ 'validation-warning' : softValidation.taxonRelationshipList.list.length }">
      <h3 class="">Type</h3>
      <expand @changed="expanded = !expanded" :expanded="expanded"></expand>
    </div>
    <div class="body" v-if="expanded">
      <div v-if="!taxonRelation">
        <hard-validation field="object_taxon_name_id">
          <autocomplete slot="body"
              url="/taxon_names/autocomplete"
              label="label_html"
              min="3"
              v-model="taxonRelation"
              eventSend="autocompleteTaxonRelationshipSelected"
              placeholder="Search taxon name for the new relationship..."
              :addParams="{ type: 'Protonym', 'nomenclature_group[]': getRankGroup }"
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
          mutation-name-modal="SetModalType"
          name-module="Types"
          display-name="subject_status_tag">
        </tree-display>
        <div class="switch-radio">
          <input name="type-picker-options" id="type-picker-common" checked type="radio" class="normal-input button-active" @click="showAdvance = false"/>
          <label for="type-picker-common">Common</label>
          <input name="type-picker-options" id="type-picker-advanced" type="radio" class="normal-input" @click="showAdvance = true"/>
          <label for="type-picker-advanced">Advanced</label>
          <input name="type-picker-options" id="type-picker-showall" type="radio" class="normal-input" @click="activeModal(true)"/>
          <label for="type-picker-showall">Show all</label>
        </div>
        <p v-html="taxonRelation.label_html"></p>
        <div class="separate-top">
          <autocomplete v-if="showAdvance"
            :arrayList="objectLists.allList"
            label="subject_status_tag"
            min="3"
            time="0"
            placeholder="Search"
            eventSend="autocompleteRelationshipSelected"
            @getItem="addEntry"
            param="term">
          </autocomplete>    
          <list-common v-if="!showAdvance" :object-lists="objectLists" @addEntry="addEntry" display="subject_status_tag" :list-created="GetRelationshipsCreated"></list-common>
        </div>
      </div>
      <list-entrys mutationNameRemove="RemoveTaxonRelationship" :list="GetRelationshipsCreated" :display="['subject_status_tag', 'object_object_tag']"></list-entrys>
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
  const getRankGroup = require('../helpers/getRankGroup');

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
      GetRelationshipsCreated() {
        return this.$store.getters[GetterNames.GetTaxonRelationshipList]
      },
      parent() {
        return this.$store.getters[GetterNames.GetParent]
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
        return this.$store.getters[GetterNames.ActiveModalType]
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
      refresh: function() {
        this.objectLists.tree = this.addType(Object.assign({},this.treeList[this.nomenclaturalCode].typification));
      },
      activeModal: function(value) {
        this.$store.commit(MutationNames.SetModalType, value)
      },
      makeLists: function() {
        return {
          tree: undefined,
        }
      },
      addEntry: function(item) {
        this.$store.dispatch(ActionNames.AddTaxonRelationship, item);
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