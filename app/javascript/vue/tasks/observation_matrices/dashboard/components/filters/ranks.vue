<template>
  <div v-if="taxonName">
    <h3>Select ranks</h3>
    <template v-for="(group, key) in ranks[taxonName.nomenclatural_code]">
      <div
        class="separate-top capitalize"
        :key="key">
        <ul class="no_bullets">
          <li
            v-for="rank in group"
            :key="rank.name">
            <label>
              <input
                v-model="ranksSelected"
                :value="rank.name"
                type="checkbox">
              {{ rank.name }}
            </label>
          </li>
        </ul>
      </div>
    </template>
  </div>
</template>

<script>

import { LoadRanks } from '../../request/resources'

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
    }
  },
  data () {
    return {
      ranks: []
    }
  },
  mounted () {
    LoadRanks().then(response => {
      this.ranks = response.body
    })
  }
}
</script>
