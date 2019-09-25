<template>
  <div v-if="taxonName">
    <h2>Select ranks</h2>
    <label>
      <input
        v-model="typicalUse"
        type="checkbox">
      Typical use
    </label>
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
  data () {
    return {
      typicalUse: true
    }
  },
  mounted () {
    LoadRanks().then(response => {
      this.ranks = response.body
    })
  }
}
</script>
