<template>
  <form v-if="parent">
    <modal
      class="transparent-modal"
      v-if="showModal"
      @close="activeModal(false)">
      <h3 slot="header">{{ nameModule }}</h3>
      <div
        slot="body"
        class="tree-list">
        <recursive-list
          :getter-list="getterList"
          :display="displayName"
          @selected="$emit('selected', $event)"
          :modal-mutation-name="mutationNameModal"
          :action-mutation-name="mutationNameAdd"
          :valid-property="validProperty"
          :object-list="objectLists.tree"/>
      </div>
    </modal>
  </form>
</template>
<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import RecursiveList from './recursiveList.vue'
import Modal from 'components/modal.vue'

export default {
  components: {
    RecursiveList,
    Modal
  },
  name: 'TreeDisplay',
  props: ['treeList', 'parent', 'showModal', 'mutationNameAdd', 'mutationNameModal', 'objectLists', 'displayName', 'nameModule', 'getterList', 'validProperty'],
  data: function () {
    return {
      showAdvance: false
    }
  },
  computed: {
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    }
  },
  mounted: function () {
    var that = this
    this.$on('closeModal', function () {
      that.showModal = false
    })
    this.$on('autocompleteStatusSelected', function (status) {
      that.addEntry(status)
    })
  },
  methods: {
    activeModal: function (value) {
      this.$emit('close', true)
      this.$store.commit(MutationNames[this.mutationNameModal], value)
    }
  }
}
</script>
