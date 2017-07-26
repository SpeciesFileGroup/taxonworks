<template>
<div v-if="parent && rankGroup && ranks[rankGroup].length">
  <modal class="taxon-modal" v-if="showModal" @close="showModal = false">
    <h3 slot="header">Status</h3>
    <div slot="body">
      <ul class="tree-status" v-for="(group, key) in Object.keys(this.ranks)" v-if="!isMajor(rankGroup, group)">
        <li v-for="(child, index) in (ranks[group])">
          <button type="button" class="button button-default" name="rankSelected" @click="setRankClass = child.rank_class, showModal = false" :value="child.rank_class"> {{ child.name }} </button> 
        </li>
      </ul>
    </div>
  </modal>
  <div class="field ranks-list">
    <h4>Rank</h4>
    <ul class="no_bullet" v-for="(group, key) in Object.keys(this.ranks)" v-if="!isMajor(rankGroup, group)">
      <li v-for="(child, index) in (ranks[group])" v-if="checkDisplay(child)">
        <label class="middle"><input type="radio" name="rankSelected" v-model="setRankClass" :checked="child.rank_class == setRankClass" :value="child.rank_class"/> {{ child.name }} </label>
      </li>
    </ul>
    <button type="button"  @click="showModal = true">Show all</button>
  </div>
  </div>
</template>
<script>

  const modal = require('../../../components/modal.vue');
  const childOfParent = require('../helpers/childOfParent')
  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;

  export default {
    components: {
      modal
    },
    computed: {
      parent() {
        return this.$store.getters[GetterNames.GetParent]
      },    
      ranks() {
        return this.$store.getters[GetterNames.GetAllRanks]
      },  
      rankGroup() {
        return this.$store.getters[GetterNames.GetParentRankGroup]
      },
      setRankClass: {
        get() {
          return this.$store.getters[GetterNames.GetRankClass];
        },
        set(value) {
          this.$store.commit(MutationNames.SetRankClass, value);
        }
      },
    },
    data: function() {
      return {
        childOfParent: childOfParent,
        showModal: false,
        defaultRanks: ['family', 'genus', 'species']
      }
    },
    watch: {
      'ranks': function(val, oldVal) {
        if(this.setRankClass == undefined) {
          this.ranks[this.childOfParent[this.rankGroup]].find(item => {
            if(this.defaultRanks.indexOf(item.name) >= 0) {
              this.setRankClass = item.rank_class;
            }
          });
        }
      },
    }, 
    methods: {
      isMajor: function(groupName, findGroup) {
        return (Object.keys(this.ranks).indexOf(groupName) > Object.keys(this.ranks).indexOf(findGroup));
      },
      checkSameRank: function(rankRadio, rank) {
        let rankSplitted = rankRadio.split('::');
        return (rank == rankSplitted[rankSplitted.length-1]);
      },
      checkDisplay: function(child) {
        return ((this.setRankClass == child.rank_class) || child.typical_use)
      }
    }
  };
</script>
<style type="text/css">
  .ranks-list ul {
    list-style: none;
    padding-left: 0px;
  }
</style>