<template>
  <div class="overflow-x-auto">
    <h2>Record number</h2>
    <div class="flex-wrap-column middle align-start full_width">
      <div class="separate-right full_width">
        <div
          v-if="store.identifiers > 1"
          class="separate-bottom"
        >
          <VIcon
            name="attention"
            color="attention"
            small
          />
          <span>
            More than one identifier exists! Use annotator to edit others.
          </span>
        </div>
        <fieldset>
          <legend>Namespace</legend>
          <div
            class="horizontal-left-content align-start separate-bottom gap-small"
          >
            <SmartSelector
              class="full_width"
              ref="smartSelectorRef"
              model="namespaces"
              input-id="record-number-namespace-autocomplete"
              target="CollectionObject"
              klass="CollectionObject"
              pin-section="Namespaces"
              pin-type="Namespace"
              :add-tabs="['new']"
              v-model="namespace"
              @selected="setNamespace"
              @on-tab-selected="handleTabChange"
            >
              <template #tabs-right>
                <VLock v-model="settings.locked.recordNumber" />
              </template>
            </SmartSelector>
            <WidgetNamespace
              ref="widgetNamespaceRef"
              @create="setNamespace"
              @close="() => smartSelectorRef.setTab('quick')"
            >
              <div />
            </WidgetNamespace>
          </div>
          <template v-if="namespace">
            <hr class="divisor" />
            <div class="middle margin-medium-top flex-separate">
              <p
                class="separate-right"
                v-html="namespace.name"
              />
              <VBtn
                v-if="store.identifier.id"
                color="destroy"
                circle
                @click="store.remove"
              >
                <VIcon
                  name="trash"
                  x-small
                />
              </VBtn>
              <VBtn
                v-else
                color="primary"
                circle
                @click="() => (store.identifier.namespaceId = id)"
              >
                <VIcon
                  name="trash"
                  x-small
                />
              </VBtn>
            </div>
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
            type="text"
            id="record-number-identifier-field"
            :class="{
              'validate-identifier': store.existingIdentifiers.length
            }"
            v-model="store.identifier.identifier"
            @input="identifierChanged"
          />
          <label>
            <input
              v-model="settings.incrementRecordNumber"
              type="checkbox"
            />
            Increment
          </label>

          <VIcon
            v-if="store.identifier.namespaceId"
            name="attention"
            color="attention"
            small
            title="Namespace and identifier needs to be set to be saved."
          />
        </div>
        <span
          v-if="
            !store.identifier.namespaceId && store.identifier.identifier?.length
          "
          class="text-warning-color"
        >
          Namespace is needed.
        </span>
        <template v-if="store.existingIdentifiers.length">
          <span class="text-error-color">
            Identifier already exists, and it won't be saved:
          </span>
          <a
            :href="store.existingIdentifiers[0].identifier_object.object_url"
            v-html="store.existingIdentifiers[0].identifier_object.object_tag"
          />
        </template>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useIdentifierStore } from '../../store/pinia/identifiers.js'
import { computed, ref, watch } from 'vue'
import { useStore } from 'vuex'
import { Namespace } from '@/routes/endpoints'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations.js'
import { IDENTIFIER_LOCAL_RECORD_NUMBER } from '@/constants/index.js'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import validateIdentifier from '../../validations/namespace.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VLock from '@/components/ui/VLock/index.vue'
import WidgetNamespace from '@/components/ui/Widget/WidgetNamespace.vue'

const DELAY = 1000
let saveRequest = undefined

const store = useIdentifierStore(IDENTIFIER_LOCAL_RECORD_NUMBER)()
const coStore = useStore()
const namespace = ref(null)
const smartSelectorRef = ref()
const widgetNamespaceRef = ref()

const coId = computed(
  () => coStore.getters[GetterNames.GetCollectionObject]?.id
)
const settings = computed({
  get() {
    return coStore.getters[GetterNames.GetSettings]
  },
  set(value) {
    coStore.commit(MutationNames.SetSettings, value)
  }
})

const checkValidation = computed(
  () =>
    !validateIdentifier({
      namespace_id: store.identifier.namespaceId,
      identifier: store.identifier.identifier
    })
)

watch(store.existingIdentifiers, (newVal) => {
  settings.value.saveIdentifier = !newVal.length
})

watch(coId, () => {
  store.existingIdentifiers = []
})

watch(
  () => store.identifier.namespaceId,
  async (id) => {
    try {
      namespace.value = id ? (await Namespace.find(id)).body : null
    } catch {
      namespace.value = null
    }
  },
  { immediate: true }
)

function identifierChanged() {
  store.identifier.isUnsaved = true
  checkIdentifier()
}

function checkIdentifier() {
  clearTimeout(saveRequest)

  if (store.identifier.identifier) {
    saveRequest = setTimeout(store.checkExistingIdentifiers, DELAY)
  } else {
    store.existingIdentifiers = []
  }
}

function handleTabChange(tab) {
  if (tab === 'new') {
    widgetNamespaceRef.value.open()
  }
}

function setNamespace({ id }) {
  store.identifier.namespaceId = id
  store.identifier.isUnsaved = true
  checkIdentifier()
}
</script>

<style scoped>
.validate-identifier {
  border: 1px solid red;
}
</style>
