<template>
  <modal
    class="transparent-modal"
    @close="$emit('close')">
    <h3 slot="header">{{ modalTitle }}</h3>
    <div
      slot="body"
      class="tree-list">
      <recursive-list
        :display="display"
        @selected="$emit('selected', $event)"
        :object-list="objectLists.tree"/>
    </div>
  </modal>
</template>
<script>

import RecursiveList from './recursiveList.vue'
import Modal from 'components/ui/Modal.vue'

export default {
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
  name: 'TreeDisplay',
  data() {
    return {
      showAdvance: false,
      showModal: true
    }
  },
  mounted() {
    var that = this
    this.$on('closeModal', function () {
      that.showModal = false
    })
  },
}
</script>
