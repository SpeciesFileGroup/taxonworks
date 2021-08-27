<template>
  <div>
    <h2>Repository</h2>
    <fieldset class="fieldset">
      <legend>Repository</legend>
      <div class="horizontal-left-content align-start separate-bottom">
        <smart-selector
          class="full_width"
          ref="smartSelector"
          model="repositories"
          target="CollectionObject"
          klass="CollectionObject"
          pin-section="Repositories"
          pin-type="Repository"
          @selected="setRepository"/>
        <lock-component
          class="margin-small-left"
          v-model="locked.collection_object.repository_id"/>
      </div>
      <template v-if="repositoryId">
        <div class="middle separate-top">
          <span data-icon="ok"/>
          <span class="separate-right"> {{ repositorySelected }}</span>
          <span
            class="circle-button button-default btn-undo"
            @click="collectionObject.repository_id = null"/>
        </div>
      </template>
    </fieldset>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import LockComponent from 'components/ui/VLock/index.vue'

import { Repository } from 'routes/endpoints'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import extendCO from './mixins/extendCO.js'

export default {
  mixins: [extendCO],

  components: {
    SmartSelector,
    LockComponent
  },

  data () {
    return {
      repositorySelected: undefined
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
    },

    repositoryId: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject].repository_id
      }
    }
  },

  watch: {
    repositoryId (newVal) {
      if (newVal) {
        Repository.find(newVal).then(response => {
          this.setRepository(response.body)
        })
      }
    }
  },

  methods: {
    setRepository (repository) {
      this.collectionObject.repository_id = repository.id
      this.repositorySelected = repository.object_tag
    }
  }
}
</script>

