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
        <div class="horizontal-right-content">
          <lock-component
            class="circle-button-margin"
            v-model="locked.collection_object.repository_id"/>
        </div>
      </div>
      <template v-if="repository">
        <div class="middle separate-top">
          <span data-icon="ok"/>
          <span class="separate-right"> {{ repositorySelected }}</span>
          <span
            class="circle-button button-default btn-undo"
            @click="repository = null"/>
        </div>
      </template>
    </fieldset>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import LockComponent from 'components/lock'

import { Repository } from 'routes/endpoints'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import refreshSmartSelector from '../shared/refreshSmartSelector'

export default {
  mixins: [refreshSmartSelector],
  components: {
    SmartSelector,
    LockComponent
  },
  computed: {
    locked: {
      get() {
        return this.$store.getters[GetterNames.GetLocked]
      },
      set(value) {
        this.$store.commit(MutationNames.SetLocked, value)
      }
    },
    collectionObject() {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    repository: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionObject].repository_id
      },
      set(value) {
        return this.$store.commit(MutationNames.SetCollectionObjectRepositoryId, value)
      }
    }
  },
  watch: {
    repository(newVal, oldVal) {
      if (newVal) {
        Repository.find(newVal).then(response => {
          this.setRepository(response.body)
        })
      }
    },
    collectionObject(newVal, oldVal) {
      if (!newVal.id || newVal.id === oldVal.id) return
      this.$refs.smartSelector.refresh()
    }
  },
  data () {
    return {
      repositorySelected: undefined
    }
  },
  methods: {
    setRepository(repository) {
      this.repository = repository.id
      this.repositorySelected = repository.object_tag
    }
  }
}
</script>

