<template>
  <div>
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
              v-model="settings.lock.identifier" />
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
</template>

<script>

import { CheckForExistingIdentifier } from 'tasks/digitize/request/resources.js'
import ValidateComponent from 'tasks/digitize/components/shared/validate.vue'
import incrementIdentifier from 'tasks/digitize/helpers/incrementIdentifier.js'
import componentExtend from '../mixins/componentExtend'
import SmartSelector from 'components/smartSelector.vue'
import LockComponent from 'components/lock'

export default {
  mixins: [componentExtend],

  components: {
    LockComponent,
    ValidateComponent,
    SmartSelector
  },

  methods: {
    increment () {
      this.identifier = incrementIdentifier(this.identifier)
    },

    checkIdentifier () {
      const that = this

      if (this.saveRequest) {
        clearTimeout(this.saveRequest)
      }
      if (this.identifier) {
        this.saveRequest = setTimeout(() => {
          CheckForExistingIdentifier(that.namespace, that.identifier).then(response => {
            that.existingIdentifier = (response.body.length > 0 ? response.body[0] : undefined)
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
