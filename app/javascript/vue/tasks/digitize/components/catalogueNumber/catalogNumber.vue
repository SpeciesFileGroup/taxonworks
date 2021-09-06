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
              v-model="namespaceSelected"
              @selected="setNamespace"/>
            <lock-component
              class="margin-small-left"
              v-model="locked.identifier" />
            <a
              class="margin-small-top margin-small-left"
              href="/namespaces/new">New</a>
          </div>
          <template v-if="identifier.namespace_id">
            <hr>
            <div class="middle flex-separate">
              <p class="separate-right">
                <span data-icon="ok"/>
                <span v-html="namespaceSelected.name"/>
              </p>
              <span
                class="circle-button button-default btn-undo"
                @click="unsetNamespace"
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
            v-model="identifier.identifier"
          >
          <label>
            <input
              v-model="settings.increment"
              type="checkbox"
            >
            Increment
          </label>
          <validate-component
            v-if="identifier.namespace_id"
            class="separate-left"
            :show-message="checkValidation"
            legend="Namespace and identifier needs to be set to be saved."
          />
        </div>
        <span
          v-if="!identifier.namespace_id && identifier.identifier && identifier.identifier.length"
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
import { IDENTIFIER_LOCAL_CATALOG_NUMBER } from 'constants/index.js'
import SmartSelector from 'components/ui/SmartSelector.vue'
import validateComponent from '../shared/validate.vue'
import validateIdentifier from '../../validations/namespace.js'
import incrementIdentifier from '../../helpers/incrementIdentifier.js'
import LockComponent from 'components/ui/VLock/index.vue'

export default {
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

    identifier: {
      get () {
        return this.$store.getters[GetterNames.GetIdentifier]
      },
      set (value) {
        return this.$store.commit(MutationNames.SetIdentifier, value)
      }
    },

    checkValidation () {
      return !validateIdentifier({ namespace_id: this.identifier.namespace_id, identifier: this.identifier.identifier })
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
      this.identifier.identifier = incrementIdentifier(this.identifier.identifier)
    },
    checkIdentifier () {
      if (this.saveRequest) {
        clearTimeout(this.saveRequest)
      }
      if (this.identifier.identifier) {
        this.saveRequest = setTimeout(() => {
          Identifier.where({
            type: IDENTIFIER_LOCAL_CATALOG_NUMBER,
            namespace_id: this.identifier.namespace_id,
            identifier: this.identifier.identifier
          }).then(response => {
            this.existingIdentifier = (response.body.length > 0 ? response.body[0] : undefined)
          })
        }, this.delay)
      }
    },
    setNamespace (namespace) {
      this.identifier.namespace_id = namespace.id
      this.checkIdentifier()
    },
    unsetNamespace () {
      this.identifier.namespace_id = undefined
      this.namespaceSelected = undefined
    }
  }
}
</script>

<style scoped>
  .validate-identifier {
    border: 1px solid red
  }
</style>
