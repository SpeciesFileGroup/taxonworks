<template>
  <div>
    <h2>Repository</h2>
    <fieldset class="fieldset">
      <legend>Repository</legend>
      <div class="margin-small-bottom">
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
          <span class="separate-right"> {{ repository.object_tag }}</span>
          <span
            class="circle-button button-default btn-undo"
            @click="setRepository({})"/>
        </div>
      </template>
    </fieldset>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import { GetRepository } from '../request/resources.js'

export default {
  components: {
    SmartSelector
  },
  props: {
    value: {
      type: Object,
      default: () => ({})
    }
  },
  computed: {
    repository: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  watch: {
    repository (newVal) {
      if (newVal) {
        GetRepository(newVal).then(response => {
          this.setRepository(response.body)
        })
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
