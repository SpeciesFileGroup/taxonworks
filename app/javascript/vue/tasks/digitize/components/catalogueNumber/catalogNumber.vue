<template>
  <div>
    <h2>Catalog number</h2>
    <div
      class="flex-wrap-column middle align-start">
      <div class="separate-right">
        <label>Namespace</label>
        <br>
        <div class="horizontal-left-content middle field">
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
      <div>
        <label>Identifier</label>
        <div class="horizontal-left-content field">
          <input
            :class="{ 'validate-identifier': existingIdentifier }"
            type="text"
            @input="checkIdentifier"
            v-model="identifier">
          <label>
            <input
              v-model="settings.increment"
              type="checkbox">
            Increment
          </label>
          <validate-component
            class="separate-left"
            :show-message="checkValidation"
            legend="Namespace and identifier needs to be set to be save."/> 
        </div>
        <span 
          v-if="existingIdentifier"
          style="color: red">Identifier already exists</span>
      </div>
    </div>
  </div>
</template>

<script>

  import Autocomplete from '../../../../components/autocomplete.vue'
  import { GetterNames } from '../../store/getters/getters'
  import { MutationNames } from '../../store/mutations/mutations.js'
  import { ActionNames } from '../../store/actions/actions'
  import { CheckForExistingIdentifier } from '../../request/resources.js'
  import validateComponent from '../shared/validate.vue'
  import validateIdentifier from '../../validations/namespace.js'
  import incrementIdentifier from '../../helpers/incrementIdentifier.js'
  import LockComponent from 'components/lock.vue'
  import BlockLayout from 'components/blockLayout.vue'

  export default {
    components: {
      Autocomplete,
      validateComponent,
      LockComponent,
      BlockLayout
    },
    computed: {
      collectionObject () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      collectionObjects() {
        return this.$store.getters[GetterNames.GetCollectionObjects]
      },
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
    data() {
      return {
        existingIdentifier: false,
        delay: 1000,
        saveRequest: undefined
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
      },
      getMacKey: function () {
        return (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt')
      },
      newDigitalization() {
        this.$store.dispatch(ActionNames.NewCollectionObject)
        this.$store.dispatch(ActionNames.NewIdentifier)
        this.$store.commit(MutationNames.NewTaxonDetermination)
        this.$store.commit(MutationNames.SetTaxonDeterminations, [])
      },
      saveCollectionObject() {
        this.$store.dispatch(ActionNames.SaveDigitalization).then(() => {
          this.$store.commit(MutationNames.SetTaxonDeterminations, [])
        })
      },
      checkIdentifier() {
        let that = this

        if(this.saveRequest) {
          clearTimeout(this.saveRequest)
        }
        this.saveRequest = setTimeout(() => { 
          CheckForExistingIdentifier(that.namespace, that.identifier).then(response => {
            that.existingIdentifier = (response.length > 0)
          })
        }, this.delay)
      }
    }
  }
</script>

<style scoped>
  .validate-identifier {
    border: 1px solid red
  }
</style>
