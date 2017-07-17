<template>
  <div class="field ranks-list" v-if="parent && rankGroup && ranks[rankGroup].length">
    <h4>Rank</h4>
    <ul class="no_bullet " v-for="(group, key) in Object.keys(this.ranks)" v-if="!isMajor(rankGroup, group) && (showAll || group == childOfParent[rankGroup])">
      <li v-if="((extendChildsList || (ranks[childOfParent[rankGroup]].lenght < maxChildsDisplay)) && (group == childOfParent[rankGroup]))">
        <label class="middle" v-if="!showAll"><input type="radio" name="extendChild" @click="showAll = true" :checked="false"/> all... </label>
        <label class="middle" v-else><input type="radio" name="extendChild" @click="showAll = false" :checked="false"/> less... </label>
      </li>
      <li v-for="(child, index) in (ranks[group])" v-if="(child.typical_use && (extendChildsList || (index < maxChildsDisplay)))">
        <label class="middle"><input type="radio" name="rankSelected" v-model="setRankClass" :checked="child.rank_class == this.setRankClass" :value="child.rank_class"/> {{ child.name }} </label>
      </li>
      <li v-if="(ranks[group].length > maxChildsDisplay) && (group == childOfParent[rankGroup]) && !showAll">
        <label class="middle" v-if="extendChildsList"><input type="radio" name="extendChild" v-model="currentMaxDisplay" @click="extendChildsList = false" :value="maxChildsDisplay" :checked="false"/> less... </label>
        <label class="middle" v-else><input type="radio" name="extendChild" v-model="currentMaxDisplay" :value="ranks[group].length" @click="extendChildsList = true" :checked="false"/> more... </label>
      </li>
    </ul>
  </div>
</template>
<script>
         
  const childOfParent = require('../helpers/childOfParent')
  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;

  export default {
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
        maxChildsDisplay: 4,
        currentMaxDisplay: 4,
        extendChildsList: false,
        showAll: false,
        defaultRanks: ['family', 'genus', 'species']
      }
    },
    watch: {
      'ranks': function(val, oldVal) {
        this.reset();
        if(this.setRankClass == undefined) {
          this.ranks[this.childOfParent[this.rankGroup]].find(item => {
            if(this.defaultRanks.indexOf(item.name) >= 0) {
              this.setRankClass = item.rank_class;
            }
          });
        }
        else {
          this.extendChildsList = true;
          this.showAll = true;
        }
      },
    }, 
    methods: {
      isMajor: function(groupName, findGroup) {
        return (Object.keys(this.ranks).indexOf(groupName) > Object.keys(this.ranks).indexOf(findGroup));
      },
      reset: function() {
        this.currentMaxDisplay = this.maxChildsDisplay;
        this.extendChildsList = false
        this.showAll = false;
      },
      checkSameRank: function(rankRadio, rank) {
        let rankSplitted = rankRadio.split('::');
        return (rank == rankSplitted[rankSplitted.length-1]);
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