<template>
  <div>
    <h2>Identifiers</h2>
    <div class="field">
      <label>Identifier</label>
      <br>
      <input 
        type="text"
        v-model="identifier.identifier">
    </div>
    <div class="field">
      <ul class="no_bullets">
        <li
          v-for="item in match"
          :key="item.value">
          <label>
            <input
              type="radio"
              :value="item.value"
              :disabled="!identifier.identifier || !identifier.identifier.length"
              v-model="identifier.identifier_exact"
              name="match-radio">
            {{ item.label }}
          </label>
        </li>
      </ul>
    </div>
    <h3>In range</h3>
    <div class="horizontal-left-content">
      <div class="field separate-right">
        <label>Start:</label>
        <br>
        <input 
          type="text"
          v-model="identifier.identifier_start">
      </div>
      <div class="field">
        <label>End:</label>
        <br>
        <input
          type="text"
          v-model="identifier.identifier_end">
      </div>
    </div>
    <h3>Namespace</h3>
    <smart-selector
      class="margin-medium-top"
      model="namespaces"
      klass="Source"
      pin-section="Namespaces"
      pin-type="Namespace"
      @selected="setNamespace"/>
    <div
      v-if="namespace"
      class="middle flex-separate separate-top">
      <span v-html="namespace.object_tag"/>
      <span 
        class="button button-circle btn-undo button-default"
        @click="unsetNamespace"/>
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
      required: true
    }
  },
  computed: {
    identifier: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  watch: {
    identifier: {
      handler(newVal) {
        if(!newVal.identifier || !newVal.identifier.length) {
          this.identifier.identifier_exact = undefined
        }
      },
      deep: true
    }
  },
  data () {
    return {
      smartLists: {},
      view: undefined,
      options: [],
      namespace: undefined,
      match: [
        {
          label: 'Exact',
          value: true
        },
        {
          label: 'Partial',
          value: undefined
        }
      ]
    }
  },
  methods: {
    setNamespace(namespace) {
      if(namespace.hasOwnProperty('label_html')) {
        namespace.object_tag = namespace.label_html
      }
      this.namespace = namespace
      this.identifier.namespace_id = namespace.id
    },
    unsetNamespace() {
      this.namespace = undefined
      this.identifier.namespace_id = undefined
    }
  }
}
</script>

<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>
