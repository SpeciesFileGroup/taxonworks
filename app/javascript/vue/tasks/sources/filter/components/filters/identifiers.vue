<template>
  <div>
    <h2>Identifiers</h2>
    <fieldset>
      <legend>Namespace</legend>
      <smart-selector
        class="margin-medium-top"
        model="namespaces"
        klass="Source"
        pin-section="Namespaces"
        pin-type="Namespace"
        @selected="setNamespace"/>
      <div
        class="horizontal-left-content"
        v-if="identifier.namespace">
        <span
          class="margin-small-right"
          v-html="identifier.namespace.object_tag"/>
        <span
          class="button circle-button btn-undo button-default"
          @click="identifier.namespace = undefined"/>
      </div>
    </fieldset>
    <div class="field label-above">
      <label>Identifier</label>
      <div class="horizontal-left-content">
        <input
          class="full_width"
          type="text">
        <button
          class="button normal-input button-default margin-small-left"
          type="button"
          @click="addIdentifier">
          Add
        </button>
      </div>
    </div>
    <div class="field label-above">
      <label>Identifier exact</label>
      <input
        v-model="params.identifier_exact"
        type="checkbox">
    </div>
    <div class="field label-above">
      <label>Identifier start</label>
      <input
        v-model="params.identifier_start"
        type="text">
    </div>
    <div class="field label-above">
      <label>Identifier end</label>
      <input
        type="text"
        v-model="params.identifier_end">
    </div>
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
      type: Object,
      default: undefined
    }
  },
  computed: {
    params: {
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
      identifiers: [],
      identifier: this.newIdentifier()
    }
  },
  watch: {
    identifiers: {
      handler (newVal) {
        this.params.identifiers = this.identifiers.map(item => {
          return {
            namespace_id: item.namespace.id,
            identifier: item.identifier
          }
        })
      },
      deep: true
    }
  },
  methods: {
    newIdentifier () {
      return {
        identifier: undefined,
        namespace: undefined
      }
    },
    setNamespace (namespace) {
      this.identifier.namespace = namespace
    },
    addIdentifier () {
      this.identifiers.push(this.identifier)
      this.identifier = this.newIdentifier()
    }
  }
}
</script>
<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>
