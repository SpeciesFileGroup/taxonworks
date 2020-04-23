<template>
  <button
    @click="create"
    type="button"
    v-if="!combination.placement.same && taxon && parent && taxon.id != parent.id"
    class="button button-submit normal-input">
    Move {{ taxon.name }} to {{ parent.name }}
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
  data () {
    return {
      taxon: undefined,
      parent: undefined
    }
  },
  mounted () {
    let protonyms = Object.values(this.combination.protonyms)
    this.taxon = protonyms.find(item => { return item.id == this.combination.placement.target_id })
    this.parent = protonyms[protonyms.length === 2 ? 1 : protonyms.length - 2]
  },
  methods: {
    create () {
      let data = {
        taxon_name: {
          id: this.combination.placement.target_id,
          parent_id: this.parent.id
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
