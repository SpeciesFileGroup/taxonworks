<template>
  <modal
    class="transparent-modal"
    v-if="showModal"
    @close="activeModal(false)">
    <h3 slot="header">{{ nameModule }}</h3>
    <div
      slot="body"
      class="tree-list">
      <recursive-list
        :display="displayName"
        @selected="$emit('selected', $event)"
        :object-list="objectLists.tree"/>
    </div>
  </modal>
</template>
<script>

import RecursiveList from './recursiveList.vue'
import Modal from 'components/modal.vue'

export default {
  components: {
    RecursiveList,
    Modal
  },
  props: {
    objectLists: {
      type: Object,
      required: true
    }
  },
  name: 'TreeDisplay',
  data() {
    return {
      showAdvance: false
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
