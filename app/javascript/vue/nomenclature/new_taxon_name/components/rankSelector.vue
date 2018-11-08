<template>
  <div v-if="existRanks()">
    <modal
      class="transparent-modal"
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Ranks</h3>
      <div slot="body">
        <ul
          class="tree-status"
          v-for="(group) in Object.keys(this.ranks)"
          v-if="!isMajor(rankGroup, group)">
          <li v-for="(child) in (ranks[group])">
            <button
              type="button"
              class="normal-input button button-default"
              name="rankSelected"
              @click="rankClass = child.rank_class, showModal = false"
              :value="child.rank_class">
              {{ child.name }}
            </button>
          </li>
        </ul>
      </div>
    </modal>
    <div class="field ranks-list">
      <h4>Rank</h4>
      <ul
        class="no_bullet"
        v-for="(group) in Object.keys(this.ranks)"
        v-if="!isMajor(rankGroup, group)">
        <li
          v-for="(child) in (ranks[group])"
          v-if="checkDisplay(child)">
          <label class="capitalize">
            <input
              type="radio"
              name="rankSelected"
              v-model="rankClass"
              :checked="child.rank_class == rankClass"
              :value="child.rank_class">
            {{ child.name }}
          </label>
        </li>
      </ul>
      <button
        type="button"
        @click="showModal = true">Show all
      </button>
    </div>
  </div>
</template>
<script>

import Modal from 'components/modal.vue'
import childOfParent from '../helpers/childOfParent'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    Modal
  },
  computed: {
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    ranks () {
      return this.$store.getters[GetterNames.GetAllRanks]
    },
    rankGroup () {
      return this.$store.getters[GetterNames.GetParentRankGroup]
    },
    rankClass: {
      get () {
        return this.$store.getters[GetterNames.GetRankClass]
      },
      set (value) {
        this.$store.commit(MutationNames.SetRankClass, value)
        this.$store.commit(MutationNames.UpdateLastChange)
      }
    }
  },
  data: function () {
    return {
      childOfParent: childOfParent,
      showModal: false,
      defaultRanks: ['family', 'genus', 'species']
    }
  },
  watch: {
    ranks: {
      handler: function (val, oldVal) {
        if (this.rankClass == undefined) {
          if (this.rankGroup) {
            this.ranks[this.childOfParent[this.rankGroup]].find(item => {
              if (this.defaultRanks.indexOf(item.name) >= 0) {
                this.rankClass = item.rank_class
              }
            })
          }
        }
      },
      deep: true,
      immediate: true
    }
  },
  methods: {
    isMajor: function (groupName, findGroup) {
      return (Object.keys(this.ranks).indexOf(groupName) > Object.keys(this.ranks).indexOf(findGroup))
    },
    checkSameRank: function (rankRadio, rank) {
      let rankSplitted = rankRadio.split('::')
      return (rank == rankSplitted[rankSplitted.length - 1])
    },
    checkDisplay: function (child) {
      return ((this.rankClass == child.rank_class) || ((this.taxon.id == undefined) && (child.typical_use)))
    },
    existRanks: function () {
      return Object.keys(this.ranks).length
    }
  }
}
</script>
<style>
  .ranks-list ul {
    list-style: none;
    padding-left: 0px;
  }
</style>
