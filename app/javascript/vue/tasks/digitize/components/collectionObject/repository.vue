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
          v-model="repositorySelected"
          @selected="setRepository"/>
        <lock-component
          class="margin-small-left"
          v-model="locked.collection_object.repository_id"/>
      </div>
      <template v-if="repositorySelected">
        <hr>
        <div class="middle flex-separate">
          <p>
            <span data-icon="ok"/>
            <span v-html="repositorySelected.object_tag"/>
          </p>
          <span
            class="circle-button button-default btn-undo"
            @click="setRepository(null)"/>
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
      } else {
        this.repositorySelected = undefined
      }
    }
  },

  methods: {
    setRepository (repository) {
      this.repositorySelected = repository
      this.collectionObject.repository_id = repository?.id
    }
  }
}
</script>
