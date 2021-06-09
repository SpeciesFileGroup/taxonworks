<template>
  <fieldset class="fieldset">
    <legend>Repository</legend>
    <div class="horizontal-left-content align-start separate-bottom align-start">
      <smart-selector
        class="full_width margin-small-right"
        ref="smartSelector"
        model="repositories"
        target="CollectionObject"
        klass="CollectionObject"
        pin-section="Repositories"
        pin-type="Repository"
        v-model="repository"/>
      <lock-component v-model="settings.lock.repository"/>
    </div>
    <template v-if="repository">
      <div class="middle separate-top">
        <span data-icon="ok"/>
        <span class="separate-right"> {{ repository.name }}</span>
        <span
          class="circle-button button-default btn-undo"
          @click="setRepository()"/>
      </div>
    </template>
  </fieldset>
</template>

<script>

import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'
import SmartSelector from 'components/ui/SmartSelector'
import LockComponent from 'components/ui/VLock/index.vue'

export default {
  components: {
    SmartSelector,
    LockComponent
  },

  computed: {
    repository: {
      get () {
        return this.$store.getters[GetterNames.GetRepository]
      },
      set (value) {
        this.$store.commit(MutationNames.SetRepository, value)
      }
    },

    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    }
  },

  methods: {
    setRepository (repository) {
      this.repository = repository
    }
  }
}
</script>
