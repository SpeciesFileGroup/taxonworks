<template>
  <div>
    <h2>Catalog number</h2>
    <div
      class="flex-wrap-column middle align-start">
      <div class="separate-right">
        <div
          v-if="identifiers > 1"
          class="separate-bottom">
          <span data-icon="warning">More than one identifier exists! Use annotator to edit others.</span>
        </div>
        <fieldset>
          <legend>Namespace</legend>
          <div class="horizontal-left-content middle field separate-bottom">
            <smart-selector
              v-model="view"
              class="separate-right"
              :options="options"/>
            <lock-component v-model="locked.identifier"/>
          </div>
          <autocomplete
            v-show="view == 'search'"
            class="separate-right"
            url="/namespaces/autocomplete"
            min="2"
            @getItem="namespace = $event.id; namespaceSelected = $event.label_html; checkIdentifier()"
            :clear-after="true"
            label="label_html"
            placeholder="Select a namespace"
            ref="autocomplete"
            param="term"/>
          <template v-if="namespace">
            <div class="middle separate-top">
              <span data-icon="ok"/>
              <p class="separate-right" v-html="namespaceSelected"/>
              <span
                class="circle-button button-default btn-undo"
                @click="namespace = undefined"/>
            </div>
          </template>
          <ul 
            class="no_bullets"
            v-if="view != 'search'">
            <li
              v-for="item in lists[view]"
              :key="item.id">
              <label>
                <input
                  type="radio"
                  :checked="item.id == namespace"
                  @click="namespace = item.id; namespaceSelected = item.object_tag; checkIdentifier()"
                  :value="item.id">
                <span v-html="item.object_tag"/>
              </label>
            </li>
          </ul>
        </fieldset>
      </div>
      <div class="separate-top">
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
            v-if="namespace"
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

  import SmartSelector from 'components/switch.vue'
  import Autocomplete from '../../../../components/autocomplete.vue'
  import { GetterNames } from '../../store/getters/getters'
  import { MutationNames } from '../../store/mutations/mutations.js'
  import { ActionNames } from '../../store/actions/actions'
  import { CheckForExistingIdentifier, GetNamespacesSmartSelector } from '../../request/resources.js'
  import validateComponent from '../shared/validate.vue'
  import validateIdentifier from '../../validations/namespace.js'
  import incrementIdentifier from '../../helpers/incrementIdentifier.js'
  import LockComponent from 'components/lock.vue'

  import orderSmartSelector from '../../helpers/orderSmartSelector.js'
  import selectFirstSmartOption from '../../helpers/selectFirstSmartOption'

  export default {
    components: {
      Autocomplete,
      validateComponent,
      LockComponent,
      SmartSelector
    },
    computed: {
      collectionObject () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      collectionObjects() {
        return this.$store.getters[GetterNames.GetCollectionObjects]
      },
      identifiers() {
        return this.$store.getters[GetterNames.GetIdentifiers]
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
      },
      namespaceSelected: {
        get() {
          return this.$store.getters[GetterNames.GetNamespaceSelected]
        },
        set(value) {
          this.$store.commit(MutationNames.SetNamespaceSelected, value)
        }
      }
    },
    data() {
      return {
        existingIdentifier: false,
        delay: 1000,
        saveRequest: undefined,
        options: [],
        lists: [],
        view: 'search'
      }
    },
    watch: {
      namespace(newVal) {
        if(!newVal) {
          this.$refs.autocomplete.cleanInput()
        }
      },
      collectionObject(newVal, oldVal) {
        if (!newVal.id || newVal.id == oldVal.id) return
        this.loadSmartSelector()
      }
    },
    mounted() {
      this.loadSmartSelector()
    },
    methods: {
      loadSmartSelector() {
        GetNamespacesSmartSelector().then(response => {
          this.options = orderSmartSelector(Object.keys(response))
          this.options.push('search')
          this.lists = response
          this.view = selectFirstSmartOption(response, this.options)
        })
      },
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
