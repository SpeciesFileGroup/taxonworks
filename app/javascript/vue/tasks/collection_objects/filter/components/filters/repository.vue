<template>
  <div>
    <h3>Repository</h3>
    <smart-selector
      v-model="repositorySelected"
      model="repositories"
      klass="CollectionObject"
      pin-section="Repositories"
      pin-type="Repository"
      @selected="setRepository"/>
    <div
      v-if="repositorySelected"
      class="middle flex-separate separate-top">
      <span v-html="repositorySelected.name"/>
      <span
        class="button button-circle btn-undo button-default"
        @click="unsetRepository"/>
    </div>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { Repository } from 'routes/endpoints'

export default {
  components: { SmartSelector },

  props: {
    modelValue: {
      type: [Number, String],
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  computed: {
    repository: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  watch: {
    repository: {
      handler (newVal) {
        if (!newVal) {
          this.repositorySelected = undefined
        }
      },
      deep: true
    }
  },

  data () {
    return {
      repositorySelected: undefined
    }
  },

  mounted () {
    const urlParams = URLParamsToJSON(location.href)
    this.repository = urlParams.repository_id
    if (urlParams.repository_id) {
      Repository.find(urlParams.repository_id).then(response => {
        this.setRepository(response.body)
      })
    }
  },
  methods: {
    setRepository (repository) {
      this.repositorySelected = repository
      this.repository = repository.id
    },
    unsetRepository () {
      this.repositorySelected = undefined
      this.repository = undefined
    }
  }
}
</script>

<style scoped>
  :deep(.vue-autocomplete-input) {
    width: 100%
  }
</style>
