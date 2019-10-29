<template>
  <button
    @click="create"
    type="button"
    v-if="!combination.placement.same"
    class="button button-submit normal-input">
    Use as current placement
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
  methods: {
    create () {
      let data = {
        taxon_name: {
          parent_id: this.combination.placement.parent_id
        }
      }
      CreatePlacement(this.combination.placement.target, data).then(response => {
        TW.workbench.alert.create(`Updated parent of ${response.name} to ${response.parent.name}`, 'notice')
        this.$emit('created', response)
      })
    }
  }
}
</script>
