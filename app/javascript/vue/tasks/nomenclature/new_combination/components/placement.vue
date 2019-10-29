<template>
  <button
    @click="create"
    type="button"
    v-if="!combination.placement.same && taxon && parent"
    class="button button-submit normal-input">
    Move {{ taxon.name }} to {{ parent.name }}
  </button>
</template>
<script>

import { CreatePlacement, GetTaxonName } from '../request/resources'

export default {
  props: {
    combination: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      taxon: undefined,
      parent: undefined
    }
  },
  mounted () {
    if(!this.combination.placement.same) {
      GetTaxonName(this.combination.placement.target_id).then(response => {
        this.taxon = response
      })
      GetTaxonName(this.combination.placement.new_parent_id).then(response => {
        this.parent = response
      })
    }
  },
  methods: {
    create () {
      let data = {
        taxon_name: {
          id: this.combination.placement.target_id,
          parent_id: this.combination.placement.new_parent_id
        }
      }
      CreatePlacement(this.combination.placement.target_id, data).then(response => {
        TW.workbench.alert.create(`Updated parent of ${response.name} to ${response.parent.name}`, 'notice')
        this.$emit('created', response)
      })
    }
  }
}
</script>
