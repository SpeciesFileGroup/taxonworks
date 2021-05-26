<template>
  <div class="protocols_annotator">
    <autocomplete
      url="/protocols/autocomplete"
      label="label"
      min="2"
      placeholder="Select a protocol"
      @getItem="createNew($event.id)"
      class="separate-bottom"
      param="term"/>
    <list-items
      target="protocols"
      label="object_tag"
      :annotator="false"
      target-citations="protocols"
      :list="list"
      @delete="removeItem"
      class="list"/>
  </div>
</template>
<script>

import CRUD from '../request/crud.js'
import annotatorExtend from '../components/annotatorExtend.js'
import autocomplete from 'components/ui/Autocomplete.vue'
import ListItems from './shared/listItems'

export default {
  mixins: [CRUD, annotatorExtend],
  components: {
    ListItems,
    autocomplete
  },
  computed: {
    validateFields () {
      return this.note.text
    }
  },
  data: function () {
    return {
      list: []
    }
  },
  methods: {
    createNew (protocol_relationship_id) {
      let data = {
        protocol_id: protocol_relationship_id,
        annotated_global_entity: decodeURIComponent(this.globalId)
      }

      this.create('/protocol_relationships', { protocol_relationship: data }).then(response => {
        this.list.push(response.body)
      })
    }
  }
}
</script>
<style lang="scss">
.radial-annotator {
	.protocols_annotator {
		.vue-autocomplete-input {
			width: 100%;
		}
	}
}
</style>
