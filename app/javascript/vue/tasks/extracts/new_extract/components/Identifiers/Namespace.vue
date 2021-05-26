<template>
  <div class="separate-right full_width">
    <fieldset>
      <legend>Namespace</legend>
      <div class="horizontal-left-content align-start separate-bottom">
        <smart-selector
          v-model="namespace"
          class="full_width"
          ref="smartSelector"
          model="namespaces"
          target="CollectionObject"
          klass="CollectionObject"
          pin-section="Namespaces"
          pin-type="Namespace"/>
        <a
          class="margin-small-top margin-small-left"
          href="/namespaces/new">New</a>
      </div>
      <template v-if="namespace">
        <div class="middle">
          <p
            class="separate-right"
            v-html="namespace.name"
          />
          <span
            class="circle-button button-default btn-undo"
            @click="namespace = undefined"
          />
        </div>
      </template>
    </fieldset>
  </div>
</template>

<script>

import componentExtend from '../mixins/componentExtend'
import SmartSelector from 'components/ui/SmartSelector.vue'

export default {
  mixins: [componentExtend],

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
    namespace: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  }

}
</script>
