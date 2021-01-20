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
          <template v-if="tripCode.namespace_id && namespace">
            <div class="middle separate-top">
              <span data-icon="ok" />
              <p
                class="separate-right"
                v-html="namespace.name"
              />
              <span
                v-if="tripCode.id"
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
import { GetNamespace, RemoveIdentifier } from '../../request/resources'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  mixins: [extendCE],
  components: {
    SmartSelector
  },
  computed: {
    tripCode: {
      get () {
        return this.$store.getters[GetterNames.GetIdentifier]
      },
      set (value) {
        this.$store.commit(MutationNames.SetIdentifier, value)
      }
    },
    namespace_id () {
      return this.tripCode.namespace_id
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
      this.tripCode.namespace_id = namespace.id
    },
    unsetIdentifier () {
      this.tripCode.namespace_id = undefined
      this.tripCode.identifier = undefined
      this.namespace = undefined
    },
    removeIdentifier () {
      RemoveIdentifier(this.tripCode.id).then(() => {
        this.unsetIdentifier()
      })
    }
  }
}
</script>
