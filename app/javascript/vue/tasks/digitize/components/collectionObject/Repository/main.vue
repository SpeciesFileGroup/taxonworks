<template>
  <div>
    <h2>Repository</h2>
    <div class="horizontal-right-content">
      <switch-component
        :options="switchOptions"
        v-model="isCurrent"
      />
    </div>
    <RepositorySelector
      v-show="isCurrent"
      v-model:lock="locked.collection_object.current_repository_id"
      :repository-id="collectionObject.current_repository_id"
      @select="collectionObject.current_repository_id = $event"
    />
    <RepositorySelector
      v-show="!isCurrent"
      v-model:lock="locked.collection_object.repository_id"
      :repository-id="collectionObject.repository_id"
      @select="collectionObject.repository_id = $event"
    />
  </div>
</template>

<script>
import { GetterNames } from '../../../store/getters/getters.js'
import { MutationNames } from '../../../store/mutations/mutations.js'
import extendCO from '../mixins/extendCO.js'
import SwitchComponent from 'tasks/observation_matrices/new/components/newMatrix/switch.vue'
import RepositorySelector from './RepositorySelector.vue'

export default {
  mixins: [extendCO],

  components: {
    SwitchComponent,
    RepositorySelector
  },

  data () {
    return {
      switchOptions: ['Current', 'Repository'],
      isCurrent: false
    }
  },

  computed: {
    locked: {
      get () {
        return this.$store.getters[GetterNames.GetLocked]
      },
      set (value) {
        this.$store.commit(MutationNames.SetLocked, value)
      }
    }
  }
}
</script>
