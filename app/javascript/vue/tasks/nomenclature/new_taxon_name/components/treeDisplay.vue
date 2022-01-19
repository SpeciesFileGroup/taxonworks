<template>
  <modal
    class="transparent-modal"
    @close="$emit('close', true)">
    <template #header>
      <h3>{{ title }}</h3>
    </template>
    <template #body>
      <div
        class="tree-list">
        <recursive-list
          :created-list="createdList"
          :display="displayName"
          @selected="$emit('selected', $event)"
          :valid-property="validProperty"
          :object-list="list"
          :taxon-rank="taxonRank"/>
      </div>
    </template>
  </modal>
</template>
<script>

import RecursiveList from './recursiveList.vue'
import Modal from 'components/ui/Modal.vue'

export default {
  name: 'TreeDisplay',

  components: {
    RecursiveList,
    Modal
  },

  props: {
    taxonRank: {
      type: String,
      required: true
    },

    list: {
      type: Object,
      required: true
    },

    displayName: {
      type: String,
      required: true
    },

    title: {
      type: String,
      required: true
    },

    validProperty: {
      type: String,
      required: true
    },

    createdList: {
      type: Array,
      default: () => []
    }
  },

  emits: ['close', 'selected']
}
</script>
