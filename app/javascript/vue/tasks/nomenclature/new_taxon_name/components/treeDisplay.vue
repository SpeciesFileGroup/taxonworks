<template>
  <form v-if="parent">
    <modal
      class="transparent-modal"
      v-if="showModal"
      @close="activeModal(false)">
      <template #header>
        <h3>{{ nameModule }}</h3>
      </template>
      <template #body>
        <div
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
      </template>
    </modal>
  </form>
</template>
<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import RecursiveList from './recursiveList.vue'
import Modal from 'components/ui/Modal.vue'

export default {
  components: {
    RecursiveList,
    Modal
  },

  name: 'TreeDisplay',

  props: ['treeList', 'parent', 'showModal', 'mutationNameAdd', 'mutationNameModal', 'objectLists', 'displayName', 'nameModule', 'getterList', 'validProperty'],

  data () {
    return {
      showAdvance: false
    }
  },
  computed: {
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    }
  },

  methods: {
    activeModal (value) {
      this.$emit('close', true)
      this.$store.commit(MutationNames[this.mutationNameModal], value)
    }
  }
}
</script>
