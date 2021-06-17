<template>
  <modal
    class="transparent-modal"
    @close="$emit('close')">
    <template #header>
      <h3>{{ modalTitle }}</h3>
    </template>
    <template #body>
      <div class="tree-list">
        <recursive-list
          :display="display"
          @selected="$emit('selected', $event)"
          :object-list="objectLists.tree"/>
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
    objectLists: {
      type: Object,
      required: true
    },
    display: {
      type: String,
      required: true
    },
    modalTitle: {
      type: String,
      required: true
    }
  },

  data () {
    return {
      showAdvance: false,
      showModal: true
    }
  }
}
</script>
