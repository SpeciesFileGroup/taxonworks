<template>
  <div class="overflow-x-auto">
    <div class="flex-separate middle">
      <h2 class="tw-section-title">Repository</h2>
      <VSwitch
        :options="switchOptions"
        v-model="repositoryView"
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
import VSwitch from '@/components/ui/VSwitch.vue'
import RepositorySelector from './RepositorySelector.vue'

export default {
  mixins: [extendCO],

  components: {
    VSwitch,
    RepositorySelector
  },

  data() {
    return {
      switchOptions: ['Current', 'Repository'],
      isCurrent: false
    }
  },

  computed: {
    repositoryView: {
      get() {
        return this.isCurrent ? this.switchOptions[0] : this.switchOptions[1]
      },
      set(value) {
        this.isCurrent = value === this.switchOptions[0]
      }
    },

    locked: {
      get() {
        return this.$store.getters[GetterNames.GetLocked]
      },
      set(value) {
        this.$store.commit(MutationNames.SetLocked, value)
      }
    }
  }
}
</script>
