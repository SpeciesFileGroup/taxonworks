<template>
  <div>
    <h2>Trip code</h2>
    <div
      class="flex-wrap-column middle align-start"
    >
      <div class="full_width">
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
          <template v-if="collectingEvent.tripCode.namespace_id && namespace">
            <div class="middle separate-top">
              <span data-icon="ok" />
              <p
                class="separate-right"
                v-html="namespace.name"
              />
              <span
                v-if="collectingEvent.tripCode.id"
                @click="removeIdentifier"
                class="circle-button btn-delete"/>
              <span
                v-else
                class="circle-button button-default btn-undo"
                @click="unsetIdentifier"
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
            v-model="collectingEvent.tripCode.identifier"
          >
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector.vue'
import extendCE from '../mixins/extendCE'
import { GetNamespace, RemoveIdentifier } from '../../request/resources'

export default {
  mixins: [extendCE],
  components: {
    SmartSelector
  },
  computed: {
    namespace_id () {
      return this.collectingEvent.tripCode.namespace_id
    }
  },
  data () {
    return {
      namespace: undefined,
    }
  },
  watch: {
    namespace_id (newVal) {
      if (newVal) {
        GetNamespace(newVal).then(response => {
          this.namespace = response.body
        })
      }
    }
  },
  methods: {
    setNamespace (namespace) {
      this.collectingEvent.tripCode.namespace_id = namespace.id
    },
    unsetIdentifier () {
      this.collectingEvent.tripCode.namespace_id = undefined
      this.collectingEvent.tripCode.identifier = undefined
      this.namespace = undefined
    },
    removeIdentifier () {
      RemoveIdentifier(this.collectingEvent.tripCode.id).then(() => {
        this.unsetIdentifier()
      })
    }
  }
}
</script>
