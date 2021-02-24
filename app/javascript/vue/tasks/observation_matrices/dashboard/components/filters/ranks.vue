<template>
  <div v-if="taxonName">
    <h3>Select ranks</h3>
    <template
      v-for="(group, key, index) in ranks[taxonName.nomenclatural_code]">
      <div
        v-if="index >= rankGroup.groupIndex"
        class="separate-top capitalize"
        :key="key">
        <ul class="no_bullets">
          <template v-for="(rank, rIndex) in group">
            <template
              v-if="!(index == rankGroup.groupIndex && rankGroup.rankIndex > rIndex)">
              <li
                :key="rank.name"
                v-if="(typicalUse ? (rank.typical_use) : true)">
                <label>
                  <input
                    v-model="ranksSelected"
                    :value="rank.name"
                    type="checkbox">
                  {{ rank.name }}
                </label>
              </li>
            </template>
          </template>
        </ul>
      </div>
    </template>
    <button
      type="button"
      class="button normal-input button-default separate-top"
      @click="typicalUse = !typicalUse">
      {{ typicalUse ? 'Show more ranks' : 'Show less ranks' }}
    </button>
  </div>
</template>

<script>

import { LoadRanks } from '../../request/resources'
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'

export default {
  props: {
    taxonName: {
      type: Object,
      default: undefined
    },
    value: {
      type: Array,
      default: () => { return [] }
    }
  },
  computed: {
    ranksSelected: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', this.orderRanks(value))
      }
    },
    ranks: {
      get () {
        return this.$store.getters[GetterNames.GetRanks]
      },
      set (value) {
        this.$store.commit(MutationNames.SetRanks, value)
      }
    },
    rankGroup () {
      const groups = this.ranks[this.taxonName.nomenclatural_code]
      let group
      let rankIndex
      for (const groupKey in groups) {
        const index = groups[groupKey].findIndex(item => {
          return item.name === this.taxonName.rank
        })
        if (index >= 0) {
          rankIndex = index
          group = groupKey
          break
        }
      }
      return { group: group, groupIndex: Object.keys(groups).findIndex(item => { return item === group }), rankIndex: rankIndex }
    }
  },
  data () {
    return {
      typicalUse: true
    }
  },
  mounted () {
    LoadRanks().then(response => {
      this.ranks = response.body
    })
  },
  methods: {
    orderRanks (ranks) {
      const rankNames = [...new Set(this.getRankNames(this.ranks))]
      const ranksOrder = rankNames.filter(rank => {
        return ranks.includes(rank)
      })
      return ranksOrder
    },
    getRankNames (list, nameList = []) {
      for (var key in list) {
        if (typeof list[key] === 'object') {
          this.getRankNames(list[key], nameList)
        } else {
          if (key === 'name') {
            nameList.push(list[key])
          }
        }
      }
      return nameList
    },
  }
}
</script>
