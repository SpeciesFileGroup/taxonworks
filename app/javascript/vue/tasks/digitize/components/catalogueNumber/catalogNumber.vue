<template>
  <div>
    <h2>Catalog number</h2>
    <div class="flex-wrap-column middle align-start full_width">
      <div class="separate-right full_width">
        <div
          v-if="identifiers > 1"
          class="separate-bottom"
        >
          <span data-icon="warning"
            >More than one identifier exists! Use annotator to edit
            others.</span
          >
        </div>
        <fieldset>
          <legend>Namespace</legend>
          <div class="horizontal-left-content align-start separate-bottom">
            <SmartSelector
              class="full_width"
              ref="smartSelector"
              model="namespaces"
              input-id="namespace-autocomplete"
              target="CollectionObject"
              klass="CollectionObject"
              pin-section="Namespaces"
              pin-type="Namespace"
              v-model="namespaceSelected"
              @selected="setNamespace"
            />
            <lock-component
              class="margin-small-left"
              v-model="locked.identifier"
            />
            <WidgetNamespace @create="setNamespace" />
          </div>
          <template v-if="namespaceSelected">
            <hr />
            <SmartSelectorItem
              :item="namespaceSelected"
              label="name"
              @unset="unsetNamespace"
            />
          </template>
        </fieldset>
      </div>
      <div
        v-help.sections.collectionObject.identifier
        class="separate-top"
      >
        <label>Identifier</label>
        <div class="horizontal-left-content field">
          <input
            id="catalog-number-identifier-field"
            :class="{
              'validate-identifier':
                existingIdentifiers.length && !isCreatedIdentifierCurrent
            }"
            type="text"
            @input="checkIdentifier"
            v-model="identifier.identifier"
          />
          <label>
            <input
              v-model="settings.increment"
              type="checkbox"
            />
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
          v-if="
            !identifier.namespace_id &&
            identifier.identifier &&
            identifier.identifier.length
          "
          style="color: red"
          >Namespace is needed.</span
        >
        <template
          v-if="existingIdentifiers.length && !isCreatedIdentifierCurrent"
        >
          <span style="color: red"
            >Identifier already exists, and it won't be saved:</span
          >
          <a
            :href="existingIdentifiers[0].identifier_object.object_url"
            v-html="existingIdentifiers[0].identifier_object.object_tag"
          />
        </template>
      </div>
    </div>
  </div>
</template>

<script setup>
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations.js'
import { Identifier } from '@/routes/endpoints'
import { IDENTIFIER_LOCAL_CATALOG_NUMBER } from '@/constants/index.js'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import validateComponent from '../shared/validate.vue'
import validateIdentifier from '../../validations/namespace.js'
import LockComponent from '@/components/ui/VLock/index.vue'
import WidgetNamespace from '@/components/ui/Widget/WidgetNamespace.vue'

import { computed, ref, watch } from 'vue'
import { useStore } from 'vuex'

const DELAY = 1000
let saveRequest = undefined

const store = useStore()
const existingIdentifiers = ref([])

const coId = computed(() => store.getters[GetterNames.GetCollectionObject]?.id)
const identifiers = computed(() => store.getters[GetterNames.GetIdentifiers])

const locked = computed({
  get() {
    return store.getters[GetterNames.GetLocked]
  },
  set(value) {
    store.commit([MutationNames.SetLocked, value])
  }
})

const settings = computed({
  get() {
    return store.getters[GetterNames.GetSettings]
  },
  set(value) {
    store.commit(MutationNames.SetSettings, value)
  }
})

const identifier = computed({
  get() {
    return store.getters[GetterNames.GetIdentifier]
  },
  set(value) {
    store.commit(MutationNames.SetIdentifier, value)
  }
})

const checkValidation = computed(
  () =>
    !validateIdentifier({
      namespace_id: identifier.value.namespace_id,
      identifier: identifier.value.identifier
    })
)

const namespaceSelected = computed({
  get() {
    return store.getters[GetterNames.GetNamespaceSelected]
  },
  set(value) {
    store.commit(MutationNames.SetNamespaceSelected, value)
  }
})

const isCreatedIdentifierCurrent = computed(() =>
  existingIdentifiers.value.find((item) => item.id === identifier.value.id)
)

watch(existingIdentifiers, (newVal) => {
  settings.value.saveIdentifier = !newVal.length
})

watch(coId, () => {
  existingIdentifiers.value = []
})

watch(
  () => identifier.value.namespace_id,
  (newVal) => {
    if (!newVal) {
      unsetNamespace()
    }
  }
)

function checkIdentifier() {
  if (saveRequest) {
    clearTimeout(saveRequest)
  }
  if (identifier.value.identifier) {
    saveRequest = setTimeout(() => {
      Identifier.where({
        type: IDENTIFIER_LOCAL_CATALOG_NUMBER,
        namespace_id: identifier.value.namespace_id,
        identifier: identifier.value.identifier
      }).then(({ body }) => {
        existingIdentifiers.value = body
      })
    }, DELAY)
  } else {
    existingIdentifiers.value = []
  }
}

function setNamespace(namespace) {
  namespaceSelected.value = namespace
  identifier.value.namespace_id = namespace.id
  checkIdentifier()
}

function unsetNamespace() {
  identifier.value.namespace_id = undefined
  namespaceSelected.value = undefined
}
</script>

<style scoped>
.validate-identifier {
  border: 1px solid red;
}
</style>
