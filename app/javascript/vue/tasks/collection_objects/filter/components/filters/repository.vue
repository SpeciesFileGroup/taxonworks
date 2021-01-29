<template>
  <div>
    <h3>Repository</h3>
    <smart-selector
      class="margin-medium-top"
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

import SmartSelector from 'components/smartSelector'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { GetRepository } from '../../request/resources'

export default {
  components: {
    SmartSelector
  },
  props: {
    value: {
      type: [Number, String],
      default: undefined
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
      GetRepository(urlParams.repository_id).then(response => {
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
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>
