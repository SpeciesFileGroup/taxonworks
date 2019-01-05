<template>
  <div>
    <h2>Catalog number</h2>
    <div class="horizontal-left-content middle align-start">
      <div class="separate-right">
        <label>Namespace</label>
        <br>
        <div class="horizontal-left-content middle">
          <autocomplete
            class="separate-right"
            url="/namespaces/autocomplete"
            min="2"
            @getItem="namespace = $event.id"
            label="label_html"
            ref="autocomplete"
            param="term"/>
          <lock-component v-model="locked.identifier"/>
        </div>
      </div>
      <div class="separate-left">
        <label>Identifier</label>
        <br>
        <input
          type="text"
          v-model="identifier">
        <br>
        <label>
          <input
            v-model="settings.increment"
            type="checkbox">
          Increment
        </label>
      </div>
      <div class="separate-left">
        <label>&nbsp;</label>
        <br>
        <validate-component
          :show-message="checkValidation"
          legend="Namespace and identifier needs to be set to be save."/>
      </div>
    </div>
  </div>
</template>

<script>

  import Autocomplete from '../../../../components/autocomplete.vue'
  import { GetterNames } from '../../store/getters/getters.js'
  import { MutationNames } from '../../store/mutations/mutations.js'
  import validateComponent from '../shared/validate.vue'
  import validateIdentifier from '../../validations/namespace.js'
  import incrementIdentifier from '../../helpers/incrementIdentifier.js'
  import LockComponent from 'components/lock.vue'

  export default {
    components: {
      Autocomplete,
      validateComponent,
      LockComponent
    },
    computed: {
      locked: {
        get() {
          return this.$store.getters[GetterNames.GetLocked]
        },
        set(value) {
          this.$store.commit([MutationNames.SetLocked, value])
        }
      },
      settings: {
        get() {
          return this.$store.getters[GetterNames.GetSettings]
        },
        set(value) {
          this.$store.commit(MutationNames.SetSettings, value)
        }        
      },
      collectionObjects() {
        return this.$store.getters[GetterNames.GetCollectionObjects]
      },
      namespace: {
        get() {
          return this.$store.getters[GetterNames.GetIdentifier].namespace_id
        },
        set(value) {
          this.$store.commit(MutationNames.SetIdentifierNamespaceId, value)
        },
      },
      identifier: {
        get() {
          return this.$store.getters[GetterNames.GetIdentifier].identifier
        },
        set(value) {
          return this.$store.commit(MutationNames.SetIdentifierIdentifier, value)
        }
      },
      coTypes: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionObjectTypes]
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionObjectTypes, value)
        }
      },
      checkValidation() {
        return !validateIdentifier({ namespace_id: this.namespace, identifier: this.identifier })
      }
    },
    watch: {
      namespace(newVal) {
        if(!newVal) {
          this.$refs.autocomplete.cleanInput()
        }
      }
    },
    methods: {
      increment() {
        this.identifier = incrementIdentifier(this.identifier)
      }
    }
  }
</script>