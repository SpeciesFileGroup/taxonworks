<template>
  <div>
    <h3>Identifier</h3>
    <fieldset>
      <legend>Namespace</legend>
      <div class="horizontal-left-content align-start separate-bottom full_width">
        <smart-selector
          class="full_width"
          ref="smartSelector"
          model="namespaces"
          target="CollectionObject"
          klass="CollectionObject"
          pin-section="Namespaces"
          pin-type="Namespace"
          @selected="setNamespace"/>
        <a
          class="margin-small-top margin-small-left"
          href="/namespaces/new">New</a>
      </div>
      <template v-if="identifier.namespace">
        <div class="middle separate-top">
          <span data-icon="ok" />
          <p
            class="separate-right"
            v-html="identifier.namespace.name"
          />
          <span
            class="circle-button button-default btn-undo"
            @click="identifier.namespace = undefined"
          />
        </div>
      </template>
    </fieldset>
    <p>Catalogue number</p>
    <div class="horizontal-left-content full_width">
      <div class="field label-above full_width">
        <label>Start</label>
        <input
          class="full_width"
          type="text"
          v-model.number="identifier.start">
      </div>
      <div class="field label-above margin-small-left full_width">
        <label>End</label>
        <input
          disabled
          class="full_width"
          :value="end"
          type="text">
      </div>
    </div>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector.vue'

export default {
  components: { SmartSelector },

  props: {
    count: {
      type: Number,
      default: 0
    },

    modelValue: {
      type: Object,
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    end () {
      return this.identifier.start + this.count - 1
    },

    identifier: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  data () {
    return {
      start: null
    }
  },

  methods: {
    setNamespace (namespace) {
      this.identifier.namespace = namespace
      this.namespace = namespace
    },

    unset () {
      this.identifier.namespace = undefined
      this.namespace = undefined
    }
  }
}
</script>

<style scoped>
  .validate-identifier {
    border: 1px solid red
  }
</style>
