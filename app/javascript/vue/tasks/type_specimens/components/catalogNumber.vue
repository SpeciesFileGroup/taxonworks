<template>
  <div>
    <h3>Catalog number</h3>
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
        v-if="namespace"
        class="horizontal-left-content">
        <span>{{ namespace.short_name }}: {{ namespace.name }}</span>
        <span
          @click="removeNamespace"
          class="button circle-button btn-undo button-default"/>
      </div>
      <div class="separate-top">
        <label>Identifier</label>
        <div class="horizontal-left-content field">
          <input
            id="identifier-field"
            :class="{ 'validate-identifier': existingIdentifier }"
            type="text"
            @input="checkIdentifier"
            v-model="identifier.identifier">
          <span
            class="margin-small-left">Namespace and identifier needs to be set to be saved.</span>
        </div>
        <span
          v-if="!namespace && identifier && identifier.length"
          style="color: red">Namespace is needed.</span>
        <template v-if="existingIdentifier">
          <span
            style="color: red">Identifier already exists, and it won't be saved:</span>
          <a
            :href="existingIdentifier.identifier_object.object_url"
            v-html="existingIdentifier.identifier_object.object_tag"/>
        </template>
      </div>
    </fieldset>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector.vue'
import { Identifier, Namespace } from 'routes/endpoints'

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    SmartSelector
  },
  computed: {
    collectionObject () {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    identifier: {
      get () {
        return this.$store.getters[GetterNames.GetIdentifier]
      },
      set (value) {
        this.$store.commit(MutationNames.SetIdentifier, value)
      }
    },
    isIdentifierDataSet () {
      return this.identifier.identifier && this.identifier.namespace_id
    },
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    }
  },
  data () {
    return {
      existingIdentifier: undefined,
      delay: 1000,
      saveRequest: undefined,
      namespace: undefined
    }
  },
  watch: {
    existingIdentifier (newVal) {
      this.settings.saveIdentifier = !newVal
    },
    identifier: {
      handler (newVal, oldVal) {
        if (newVal.namespace_id) {
          if (newVal.namespace_id !== oldVal.namespace_id) {
            Namespace.find(newVal.namespace_id).then(response => {
              this.namespace = response.body
            })
          }
        } else {
          this.namespace = undefined
        }
      },
      deep: true
    }
  },
  methods: {
    checkIdentifier () {
      if (this.saveRequest) {
        clearTimeout(this.saveRequest)
      }
      if (this.isIdentifierDataSet) {
        this.saveRequest = setTimeout(() => {
          Identifier.where({
            type: 'Identifier::Local::CatalogNumber',
            namespace_id: this.namespace.id,
            identifier: this.identifier.identifier
          }).then(response => {
            this.existingIdentifier = (response.body.length > 0 ? response.body[0] : false)
          })
        }, this.delay)
      }
    },
    setNamespace (namespace) {
      this.namespace = namespace
      this.identifier.namespace_id = namespace.id
    },
    removeNamespace () {
      this.namespace = undefined
      this.identifier.namespace_id = undefined
    }
  }
}
</script>

<style scoped>
  .validate-identifier {
    border: 1px solid red
  }
</style>
