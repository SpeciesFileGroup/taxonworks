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
          <NamespaceForm
            v-model="store.namespace"
            @selected="namespaceSelected"
          />
        </div>
        <div class="separate-top">
          <label>Identifier</label>
          <div class="horizontal-left-content field">
            <input
              id="identifier-field"
              :class="{
                'validate-identifier':
                  existingIdentifier && !isCreatedIdentifierCurrent
              }"
              type="text"
              @input="findExistingIdentifier"
              @change="() => (store.identifier.isUnsaved = true)"
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
            v-if="!store.namespace && store.identifier.identifier"
            style="color: red"
            >Namespace is needed.</span
          >
          <template v-if="existingIdentifier && !isCreatedIdentifierCurrent">
            <span style="color: red"
              >Identifier already exists, and it won't be saved:</span
            >
            <a
              :href="existingIdentifier.identifier_object.object_url"
              v-html="existingIdentifier.identifier_object.object_tag"
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
import { IDENTIFIER_LOCAL_CATALOG_NUMBER } from '@/constants/index.js'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import validateComponent from '@/tasks/digitize/components/shared/validate.vue'
import validateIdentifier from '@/tasks/digitize/validations/namespace.js'
import useStore from '../../../store/identifier.js'
import useSettings from '../../../store/settings.js'
import NamespaceForm from './NamespaceForm.vue'

const DELAY = 1000
const store = useStore()
const settings = useSettings()
const existingIdentifier = ref()
let timeOut

const checkValidation = computed(
  () =>
    !validateIdentifier({
      namespace_id: store.identifier.namespace_id,
      identifier: store.identifier.identifier
    })
)

const isCreatedIdentifierCurrent = computed(
  () => existingIdentifier.value.id === store.identifier.id
)

watch(existingIdentifier, (newVal) => {
  settings.saveIdentifier = !newVal
})

function findExistingIdentifier() {
  if (timeOut) {
    clearTimeout(timeOut)
  }
  if (store.identifier.identifier && store.namespace) {
    timeOut = setTimeout(() => {
      Identifier.where({
        type: IDENTIFIER_LOCAL_CATALOG_NUMBER,
        namespace_id: store.namespace.id,
        identifier: store.identifier.identifier
      }).then(({ body }) => {
        const [identifier] = body

        existingIdentifier.value = identifier
      })
    }, DELAY)
  }
}

function namespaceSelected() {
  store.identifier.isUnsaved = true
  findExistingIdentifier()
}
function unsetNamespace() {
  store.namespace = undefined
}
</script>

<style scoped>
.validate-identifier {
  border: 1px solid red;
}
</style>
