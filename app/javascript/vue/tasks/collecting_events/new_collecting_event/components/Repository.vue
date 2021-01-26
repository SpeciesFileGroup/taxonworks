<template>
  <div>
    <h3>Repository</h3>
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
            @click="unsetRepository"/>
        </div>
      </template>
    </fieldset>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'

export default {
  components: {
    SmartSelector
  },
  props: {
    value: {
      type: [String, Number],
      default: undefined
    }
  },
  computed: {
    repositoryId: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      repository: undefined
    }
  },
  methods: {
    setRepository (repository) {
      this.repository = repository
      this.repositoryId = repository.id
    },
    unsetRepository () {
      this.repository = undefined
      this.repositoryId = undefined
    }
  }
}
</script>
