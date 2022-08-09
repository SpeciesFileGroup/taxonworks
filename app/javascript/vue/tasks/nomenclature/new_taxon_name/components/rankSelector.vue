<template>
  <div v-if="existRanks()">
    <modal
      class="transparent-modal"
      v-if="showModal"
      @close="showModal = false">
      <template #header>
        <h3>Ranks</h3>
      </template>
      <template #body>
        <template v-for="(group) in Object.keys(this.ranks)">
          <ul
            class="tree-status"
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
        </template>
      </template>
    </modal>
    <div class="field ranks-list">
      <h4>Rank</h4>
      <template v-for="(group) in Object.keys(this.ranks)">
        <ul
          class="no_bullet"
          v-if="!isMajor(rankGroup, group)">
          <template v-for="(child) in (ranks[group])">
            <li v-if="checkDisplay(child)">
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
          </template>
        </ul>
      </template>
      <button
        type="button"
        class="button normal-input button-default"
        @click="showModal = true">Show all
      </button>
    </div>
  </div>
</template>
<script>

import Modal from 'components/ui/Modal.vue'
import childOfParent from '../helpers/childOfParent'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { TaxonName } from 'routes/endpoints'

export default {
  components: {
    Modal
  },
  computed: {
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    parent () {
      return this.$store.getters[GetterNames.GetParent]
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
    },
    taxonName () {
      return this.$store.getters[GetterNames.GetTaxonName]
    }
  },
  data () {
    return {
      childOfParent: childOfParent,
      showModal: false,
      defaultRanks: ['family', 'genus', 'species'],
      timer: undefined
    }
  },
  watch: {
    parent: {
      handler (newVal, oldVal) {
        if (oldVal) {
          if (!this.taxon.id) {
            this.rankClass = undefined
          }
        }
        if (newVal && !this.taxon.id) {
          TaxonName.predictedRank(newVal.id, this.taxon.name).then(response => {
            if (response.body.predicted_rank.length) {
              this.rankClass = response.body.predicted_rank
            }
          })
        }
      },
      deep: true,
      immediate: true
    },
    taxonName: {
      handler (newVal, oldVal) {
        if (!this.taxon.id && this.parent && newVal.length && newVal !== oldVal) {
          clearTimeout(this.timer)

          const that = this
          this.timer = setTimeout(() => {
            TaxonName.predictedRank(that.parent.id, that.taxon.name).then(response => {
              if (response.body.predicted_rank.length) {
                that.rankClass = response.body.predicted_rank
              }
            })
          }, 500)
        }
      },
      deep: true
    }
  },
  methods: {
    refresh () {
      if (!this.rankClass && !this.taxon.id) {
        if (this.rankGroup) {
          this.ranks[this.childOfParent[this.rankGroup]].find(item => {
            if (this.defaultRanks.indexOf(item.name) >= 0) {
              this.rankClass = item.rank_class
            }
          })
        }
      }
    },

    isMajor (groupName, findGroup) {
      return (Object.keys(this.ranks).indexOf(groupName) > Object.keys(this.ranks).indexOf(findGroup))
    },

    checkSameRank (rankRadio, rank) {
      const rankSplitted = rankRadio.split('::')
      return (rank === rankSplitted[rankSplitted.length - 1])
    },

    checkDisplay (child) {
      return ((this.rankClass === child.rank_class) || ((!this.taxon.id) && (child.typical_use)))
    },

    existRanks () {
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
