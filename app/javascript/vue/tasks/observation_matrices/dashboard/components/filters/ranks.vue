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
            <li
              :key="rank.name"
              v-if="rankGroup.rankIndex <= rIndex && index >= rankGroup.groupIndex">
              <label>
                <input
                  v-model="ranksSelected"
                  :value="rank.name"
                  type="checkbox">
                {{ rank.name }}
              </label>
            </li>
          </template>
        </ul>
      </div>
    </template>
  </div>
</template>

<script>

import { LoadRanks } from '../../request/resources'
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'
import GetRankNames from '../../helpers/getRankNames'

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
        this.$emit('input', value)
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
  mounted () {
    LoadRanks().then(response => {
      this.ranks = response.body
    })
  },
  methods: {

  }
}
</script>
