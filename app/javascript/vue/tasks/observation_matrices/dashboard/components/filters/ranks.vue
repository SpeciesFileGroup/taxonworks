<template>
  <div v-if="taxonName">
    <h3>Select ranks</h3>
    <template v-for="group in ranks[taxonName.nomenclatural_code]">
      <div class="separate-top capitalize">
        <ul
          v-for="rank in group"
          class="no_bullets">
          <li>
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
  watch: {
    taxonName: {
      handler () {
        console.log("yes")
      },
      deep: true
    }
  },
  mounted () {
    LoadRanks().then(response => {
      this.ranks = response.body
    })
  }
}
</script>
