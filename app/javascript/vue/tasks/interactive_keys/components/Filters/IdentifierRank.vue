<template>
  <div>
    <label class="display-block">Identified to rank</label>
    <select v-model="rankSelected">
      <option
        v-for="(rank, index) in ranks"
        :key="index">
        {{ rank }}
      </option>
    </select>
  </div>
</template>

<script>

export default {
  props: {
    value: {
      type: String,
      default: undefined
    }
  },

  computed: {
    rankSelected: {
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
      ranks: [undefined, 'otu', 'subspecies', 'species', 'subgenus', 'genus', 'subtribe', 'tribe', 'subfamily', 'family']
    }
  }
}
</script>
