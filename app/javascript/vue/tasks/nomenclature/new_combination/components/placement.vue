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

import { CreatePlacement } from '../request/resources'

export default {
  props: {
    combination: {
      type: Object,
      required: true
    }
  },
  computed: {
    parentName () {
      if (!this.parent) return
      return Object.keys(this.combination.protonyms)[1] === 'subgenus' ? `${this.protonyms[2].name} (${this.parent.name})` : this.parent.name
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
    this.protonyms = this.mapOrder(Object.values(this.combination.protonyms), this.ranks, 'rank')
    this.taxon = this.protonyms[0]
    this.parent = this.protonyms[1]
  },
  methods: {
    create () {
      let data = {
        taxon_name: {
          id: this.taxon.id,
          parent_id: this.parent.id
        }
      }
      CreatePlacement(this.taxon.id, data).then(response => {
        TW.workbench.alert.create(`Updated parent of ${response.name} to ${response.parent.name}`, 'notice')
        this.$emit('created', response)
      })
    },
    mapOrder (array, order, key) {
      array.sort( function (a, b) {
        var A = a[key], B = b[key];

        if (order.indexOf(A) > order.indexOf(B)) {
          return 1;
        } else {
          return -1;
        }
        
      });
      
      return array;
    }

  }
}
</script>
