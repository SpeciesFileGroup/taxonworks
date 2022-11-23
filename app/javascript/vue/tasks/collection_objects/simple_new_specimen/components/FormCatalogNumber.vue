<template>
  <div class="panel content">
    <h2>Catalog number</h2>
    <fieldset>
      <legend>Namespace</legend>
      <SmartSelector
        model="namespaces"
        :klass="COLLECTION_OBJECT"
        v-model="store.namespace"
      >
        <template #tabs-right>
          <VLock
            class="margin-small-left"
            v-model="store.settings.lock.namespace"
          />
        </template>
      </SmartSelector>
      <hr v-if="store.namespace">
      <SmartSelectorItem
        :item="store.namespace"
        label="name"
        @unset="store.namespace = undefined"
      />
    </fieldset>

    <div class="separate-top">
      <label>Identifier</label>
      <div class="horizontal-left-content field">
        <input
          id="identifier-field"
          :class="{ 'validate-identifier': store.createdIdentifiers.length }"
          type="text"
          @input="checkIdentifier"
          v-model="store.identifier"
        >
        <label>
          <input
            v-model="store.settings.increment"
            type="checkbox"
          >
          Increment
        </label>
      </div>
      <span
        v-if="!store.namespace && store.identifier"
        style="color: red"
      >
        Namespace is needed.
      </span>
      <template v-if="store.createdIdentifiers.length">
        <span
          style="color: red"
        >Identifier already exists, and it won't be saved:</span>
        <a
          :href="store.createdIdentifiers[0].identifier_object.object_url"
          v-html="store.createdIdentifiers[0].identifier_object.object_tag"
        />
      </template>
    </div>
  </div>
</template>

<script setup>
import { useStore } from '../store/useStore'
import { COLLECTION_OBJECT } from 'constants/index'
import SmartSelector from 'components/ui/SmartSelector.vue'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import VLock from 'components/ui/VLock/index.vue'

const store = useStore()
const DELAY = 1000
let timeoutRequest

function checkIdentifier () {
  clearTimeout(timeoutRequest)

  timeoutRequest = setTimeout(() => {
    store.getIdentifiers()
  }, DELAY)
}

</script>
