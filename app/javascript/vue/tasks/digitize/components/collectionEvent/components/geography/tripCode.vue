<template>
  <div>
    <h2>Trip code</h2>
    <div
      class="flex-wrap-column middle align-start">
      <div class="separate-right">
        <fieldset>
          <legend>Namespace</legend>
          <div class="horizontal-left-content middle field separate-bottom">
            <smart-selector
              v-model="view"
              class="separate-right item"
              :options="options"/>
          </div>
          <autocomplete
            v-show="view == 'search'"
            class="separate-right"
            url="/namespaces/autocomplete"
            min="2"
            @getItem="identifier.namespace_id = $event.id; namespaceSelected = $event.label_html;"
            :clear-after="true"
            label="label_html"
            placeholder="Select a namespace"
            ref="autocomplete"
            param="term"/>
          <template v-if="identifier.namespace_id">
            <div class="middle separate-top">
              <span data-icon="ok"/>
              <p class="separate-right" v-html="namespaceSelected"/>
              <span
                class="circle-button button-default btn-undo"
                @click="identifier.namespace_id = undefined"/>
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
                  :checked="item.id == identifier.namespace_id"
                  @click="identifier.namespace_id = item.id; namespaceSelected = item.object_tag;"
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
            type="text"
            v-model="identifier.identifier">
          <validate-component
            v-if="identifier.namespace_id"
            class="separate-left"
            :show-message="checkValidation"
            legend="Namespace and identifier needs to be set to be save."/> 
        </div>
      </div>
    </div>
  </div>
</template>

<script>

  import SmartSelector from 'components/switch.vue'
  import Autocomplete from 'components/autocomplete.vue'
  import { GetterNames } from '../../../../store/getters/getters'
  import { MutationNames } from '../../../../store/mutations/mutations.js'
  import { ActionNames } from '../../../../store/actions/actions'
  import { GetNamespacesSmartSelector } from '../../../../request/resources.js'
  import validateComponent from '../../../shared/validate.vue'
  import validateIdentifier from '../../../../validations/namespace.js'

  import orderSmartSelector from '../../../../helpers/orderSmartSelector.js'
  import selectFirstSmartOption from '../../../../helpers/selectFirstSmartOption'

  export default {
    components: {
      Autocomplete,
      validateComponent,
      SmartSelector
    },
    computed: {
      identifier: {
        get() {
          return this.$store.getters[GetterNames.GetCollectingEventIdentifier]
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionEventIdentifier, value)
        }
      },
      checkValidation() {
        return !validateIdentifier({ namespace_id: this.identifier.namespace_id, identifier: this.identifier.identifier })
      }
    },
    data () {
      return {
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
      getMacKey: function () {
        return (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt')
      },
    }
  }
</script>

<style scoped>
  .validate-identifier {
    border: 1px solid red
  }
</style>
