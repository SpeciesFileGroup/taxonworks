<template>
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
    </div>
    <template v-if="repository">
      <div class="middle separate-top">
        <span data-icon="ok"/>
        <span class="separate-right"> {{ repository.name }}</span>
        <span
          class="circle-button button-default btn-undo"
          @click="unsetRepository()"/>
      </div>
    </template>
  </fieldset>
</template>

<script>

import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'
import SmartSelector from 'components/smartSelector'

export default {
  components: { SmartSelector },

  computed: {
    repository: {
      get () {
        return this.$store.getters[GetterNames.GetRepository]
      },
      set (value) {
        this.$store.commit(MutationNames.SetRepository, value)
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
