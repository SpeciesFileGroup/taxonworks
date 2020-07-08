<template>
  <div>
    <h2>Trip code</h2>
    <div
      class="flex-wrap-column middle align-start"
    >
      <div class="separate-right">
        <fieldset>
          <legend>Namespace</legend>
          <smart-selector
            class="full_width"
            ref="smartSelector"
            model="namespaces"
            target="CollectingEvent"
            klass="CollectingEvent"
            v-model="namespace"
            @selected="setNamespace"
          />
          <template v-if="tripCode.namespace_id">
            <div class="middle separate-top">
              <span data-icon="ok" />
              <p
                class="separate-right"
                v-html="namespaceSelected ? namespaceSelected : identifier.cached"
              />
              <span
                class="circle-button button-default btn-undo"
                @click="tripCode.namespace_id = undefined"
              />
            </div>
          </template>
        </fieldset>
      </div>
      <div class="separate-top">
        <label>Identifier</label>
        <div class="horizontal-left-content field">
          <input
            type="text"
            v-model="tripCode.identifier"
          >
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector.vue'
import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE],
  components: {
    SmartSelector
  },
  data () {
    return {
      namespace: undefined,
      tripCode: {
        id: undefined,
        namespace_id: undefined,
        type: 'Identifier::Local::TripCode',
        identifier: undefined
      }
    }
  },
  methods: {
    setNamespace (namespace) {
      this.tripCode.namespace_id = namespace.id
    }
  }
}
</script>
