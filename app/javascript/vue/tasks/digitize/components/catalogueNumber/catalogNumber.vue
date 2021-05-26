<template>
  <div>
    <h2>Catalog number</h2>
    <div
      class="flex-wrap-column middle align-start full_width"
    >
      <div class="separate-right full_width">
        <div
          v-if="identifiers > 1"
          class="separate-bottom"
        >
          <span data-icon="warning">More than one identifier exists! Use annotator to edit others.</span>
        </div>
        <fieldset>
          <legend>Namespace</legend>
          <div class="horizontal-left-content align-start separate-bottom">
            <smart-selector
              class="full_width"
              ref="smartSelector"
              model="namespaces"
              input-id="namespace-autocomplete"
              target="CollectionObject"
              klass="CollectionObject"
              pin-section="Namespaces"
              pin-type="Namespace"
              @selected="setNamespace"/>
            <div class="horizontal-right-content">
              <lock-component
                class="circle-button-margin"
                v-model="locked.identifier" />
            </div>
            <a 
              class="margin-small-top margin-small-left"
              href="/namespaces/new">New</a>
          </div>
          <template v-if="namespace">
            <div class="middle separate-top">
              <span data-icon="ok" />
              <p
                class="separate-right"
                v-html="namespaceSelected"
              />
              <span
                class="circle-button button-default btn-undo"
                @click="namespace = undefined"
              />
            </div>
          </template>
        </fieldset>
      </div>
      <div
        v-help.sections.collectionObject.identifier
        class="separate-top">
        <label>Identifier</label>
        <div class="horizontal-left-content field">
          <input
            id="identifier-field"
            :class="{ 'validate-identifier': existingIdentifier }"
            type="text"
            @input="checkIdentifier"
            v-model="identifier"
          >
          <label>
            <input
              v-model="settings.increment"
              type="checkbox"
            >
            Increment
          </label>
          <validate-component
            v-if="namespace"
            class="separate-left"
            :show-message="checkValidation"
            legend="Namespace and identifier needs to be set to be saved."
          />
        </div>
        <span
          v-if="!namespace && identifier && identifier.length"
          style="color: red"
        >Namespace is needed.</span>
        <template v-if="existingIdentifier">
          <span
            style="color: red"
          >Identifier already exists, and it won't be saved:</span>
          <a
            :href="existingIdentifier.identifier_object.object_url"
            v-html="existingIdentifier.identifier_object.object_tag"
          />
        </template>
      </div>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations.js'
import { Identifier } from 'routes/endpoints'
import SmartSelector from 'components/ui/SmartSelector.vue'
import validateComponent from '../shared/validate.vue'
import validateIdentifier from '../../validations/namespace.js'
import incrementIdentifier from '../../helpers/incrementIdentifier.js'
import LockComponent from 'components/lock.vue'
import refreshSmartSelector from '../shared/refreshSmartSelector'

export default {
  mixins: [refreshSmartSelector],
  components: {
    validateComponent,
    LockComponent,
    SmartSelector
  },
  computed: {
    collectionObject () {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    identifiers () {
      return this.$store.getters[GetterNames.GetIdentifiers]
    },
    locked: {
      get () {
        return this.$store.getters[GetterNames.GetLocked]
      },
      set (value) {
        this.$store.commit([MutationNames.SetLocked, value])
      }
    },
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    },
    namespace: {
      get () {
        return this.$store.getters[GetterNames.GetIdentifier].namespace_id
      },
      set (value) {
        this.$store.commit(MutationNames.SetIdentifierNamespaceId, value)
      }
    },
    identifier: {
      get () {
        return this.$store.getters[GetterNames.GetIdentifier].identifier
      },
      set (value) {
        return this.$store.commit(MutationNames.SetIdentifierIdentifier, value)
      }
    },
    checkValidation () {
      return !validateIdentifier({ namespace_id: this.namespace, identifier: this.identifier })
    },
    namespaceSelected: {
      get () {
        return this.$store.getters[GetterNames.GetNamespaceSelected]
      },
      set (value) {
        this.$store.commit(MutationNames.SetNamespaceSelected, value)
      }
    }
  },
  data () {
    return {
      existingIdentifier: undefined,
      delay: 1000,
      saveRequest: undefined
    }
  },
  watch: {
    existingIdentifier (newVal) {
      this.settings.saveIdentifier = !newVal
    }
  },
  methods: {
    increment () {
      this.identifier = incrementIdentifier(this.identifier)
    },
    checkIdentifier () {
      if (this.saveRequest) {
        clearTimeout(this.saveRequest)
      }
      if (this.identifier) {
        this.saveRequest = setTimeout(() => {
          Identifier.where({
            type: 'Identifier::Local::CatalogNumber',
            namespace_id: this.namespace,
            identifier: this.identifier
          }).then(response => {
            this.existingIdentifier = (response.body.length > 0 ? response.body[0] : undefined)
          })
        }, this.delay)
      }
    },
    setNamespace (namespace) {
      this.namespace = namespace.id
      this.namespaceSelected = namespace.name
      this.checkIdentifier()
    }
  }
}
</script>

<style scoped>
  .validate-identifier {
    border: 1px solid red
  }
</style>
