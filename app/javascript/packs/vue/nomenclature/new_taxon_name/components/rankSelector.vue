<template>
  <div class="field" v-if="parent && ranks[parent.rankGroup].length">
    <label>Rank</label><br>
    <ul v-for="(group, key) in Object.keys(this.ranks)" v-if="!isMajor(parent.rankGroup, group) && (showAll || group == childOfParent[parent.rankGroup])">
      <li v-if="((extendChildsList || (ranks[childOfParent[parent.rankGroup]].lenght < maxChildsDisplay)) && (group == childOfParent[parent.rankGroup]))">
        <label v-if="!showAll"><input type="radio" name="extendChild" @click="showAll = true" :checked="false"/> all... </label>
        <label v-else><input type="radio" name="extendChild" @click="showAll = false" checked="false"/> less... </label>
      </li>
      <li v-for="(child, index) in (ranks[group])" v-if="((extendChildsList || (index < maxChildsDisplay)))">
        <label><input type="radio" name="rankSelected" v-model="setRankClass" :value="child.rank_class"/> {{ child.name }} </label>
      </li>
      <li v-if="(ranks[group].length > maxChildsDisplay) && (group == childOfParent[parent.rankGroup]) && !showAll">
        <label v-if="extendChildsList"><input type="radio" name="extendChild" v-model="currentMaxDisplay" @click="extendChildsList = false" :value="maxChildsDisplay"/> less... </label>
        <label v-else><input type="radio" name="extendChild" v-model="currentMaxDisplay" :value="ranks[group].length" @click="extendChildsList = true"/> more... </label>
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
        this.ranks[this.childOfParent[this.parent.rankGroup]].find(item => {
          if(this.defaultRanks.indexOf(item.name) >= 0) {
            this.setRankClass = item.rank_class;
          }
        });
      },
    }, methods: {
      isMajor: function(groupName, findGroup) {
        return (Object.keys(this.ranks).indexOf(groupName) > Object.keys(this.ranks).indexOf(findGroup));
      },
      reset: function() {
        this.currentMaxDisplay = this.maxChildsDisplay;
        this.extendChildsList = false
        this.showAll = false;
      }
    }
  };
</script>