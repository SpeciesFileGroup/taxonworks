<template>
  <button
    @click="create"
    type="button"
    v-if="!combination.placement.same && taxon && parent && taxon.parent_id != parent.id"
    class="button button-submit normal-input">
    Move {{ taxon.name }} to {{ parentName }}
  </button>
</template>
<script>

import { TaxonName } from 'routes/endpoints'

export default {
  props: {
    combination: {
      type: Object,
      required: true
    }
  },

  emits: ['created'],

  computed: {
    parentName () {
      if (!this.parent) return
      this.protonyms.some((item, index) => {
        if (this.protonyms[index].rank === 'subgenus') {
          this.protonyms[index].taxon.name = `(${this.protonyms[index].taxon.name})`
          return true
        }
        return false
      })
      return this.protonyms.slice(1).reverse().map(protonym => { return protonym.taxon.name }).join(' ')
    }
  },
  data () {
    return {
      taxon: undefined,
      parent: undefined,
      protonyms: [],
      ranks: ['subspecies', 'species', 'subgenus', 'genus']
    }
  },
  mounted () {
    this.orderRanks()
    this.taxon = this.protonyms[0].taxon
    if (this.protonyms[1]) {
      this.parent = this.protonyms[1].taxon
    }
  },
  methods: {
    create () {
      const data = {
        taxon_name: {
          id: this.taxon.id,
          parent_id: this.parent.id
        }
      }
      TaxonName.update(this.taxon.id, data).then(response => {
        TW.workbench.alert.create(`Updated parent of ${response.body.name} to ${response.body.parent.name}`, 'notice')
        this.$emit('created', response.body)
      })
    },
    orderRanks () {
      this.ranks.forEach(rank => {
        if (this.combination.protonyms[rank]) {
          this.protonyms.push({ rank: rank, taxon: this.combination.protonyms[rank] })
        }
      })
    },
    mapOrder (array, order, key) {
      array.sort((a, b) => {
        const A = a[key]
        const B = b[key]
        if (order.indexOf(A) > order.indexOf(B)) {
          return 1
        } else {
          return -1
        }
      })
      return array
    }
  }
}
</script>
