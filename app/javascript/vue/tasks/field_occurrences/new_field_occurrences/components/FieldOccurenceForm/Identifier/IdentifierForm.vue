<template>
  <BlockLayout>
    <template #header>
      <h3>Catalog number</h3>
    </template>
    <template #body>
      <div class="flex-wrap-column middle align-start full_width">
        <div class="separate-right full_width">
          <div
            v-if="store.identifiers > 1"
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
                model="namespaces"
                input-id="namespace-autocomplete"
                :target="FIELD_OCCURRENCE"
                :klass="FIELD_OCCURRENCE"
                pin-section="Namespaces"
                pin-type="Namespace"
                v-model="store.namespace"
                @selected="setNamespace"
              />
              <a
                class="margin-small-top margin-small-left"
                href="/namespaces/new"
                >New</a
              >
            </div>
            <template v-if="store.identifier.namespace_id">
              <hr />
              <div class="middle flex-separate">
                <p class="separate-right">
                  <span data-icon="ok" />
                  <span v-html="store.namespace.name" />
                </p>
                <span
                  class="circle-button button-default btn-undo"
                  @click="unsetNamespace"
                />
              </div>
            </template>
          </fieldset>
        </div>
        <div class="separate-top">
          <label>Identifier</label>
          <div class="horizontal-left-content field">
            <input
              id="identifier-field"
              :class="{
                'validate-identifier':
                  existingIdentifiers.length && !isCreatedIdentifierCurrent
              }"
              type="text"
              @input="checkIdentifier"
              v-model="store.identifier.identifier"
            />
            <label>
              <input
                v-model="store.increment"
                type="checkbox"
              />
              Increment
            </label>
            <validate-component
              v-if="store.identifier.namespace_id"
              class="separate-left"
              :show-message="checkValidation"
              legend="Namespace and identifier needs to be set to be saved."
            />
          </div>
          <span
            v-if="
              !store.identifier.namespace_id &&
              store.identifier.identifier &&
              store.identifier.identifier.length
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
    </template>
  </BlockLayout>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { Identifier } from '@/routes/endpoints'
import {
  IDENTIFIER_LOCAL_CATALOG_NUMBER,
  FIELD_OCCURRENCE
} from '@/constants/index.js'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import validateComponent from '@/tasks/digitize/components/shared/validate.vue'
import validateIdentifier from '@/tasks/digitize/validations/namespace.js'
import useStore from '../../../store/identifier.js'
import useSettings from '../../../store/settings.js'

const DELAY = 1000
const store = useStore()
const settings = useSettings()
const existingIdentifiers = ref([])
let saveRequestTimeout

const checkValidation = computed(
  () =>
    !validateIdentifier({
      namespace_id: store.identifier.namespace_id,
      identifier: store.identifier.identifier
    })
)

const isCreatedIdentifierCurrent = computed(() =>
  existingIdentifiers.value.find((item) => item.id === store.identifier.id)
)

watch(existingIdentifiers, (newVal) => {
  settings.saveIdentifier = !newVal.lnegth
})

function findExistingIdentifier() {
  if (saveRequestTimeout) {
    clearTimeout(saveRequestTimeout)
  }
  if (store.identifier.identifier) {
    saveRequestTimeout = setTimeout(() => {
      Identifier.where({
        type: IDENTIFIER_LOCAL_CATALOG_NUMBER,
        namespace_id: store.identifier.namespace_id,
        identifier: store.identifier.identifier
      }).then(({ body }) => {
        existingIdentifiers.value = body
      })
    }, DELAY)
  }
}

function setNamespace(namespace) {
  store.identifier.namespace_id = namespace.id
  findExistingIdentifier()
}
function unsetNamespace() {
  store.identifier.namespace_id = undefined
  store.namespace = undefined
}
</script>

<style scoped>
.validate-identifier {
  border: 1px solid red;
}
</style>
