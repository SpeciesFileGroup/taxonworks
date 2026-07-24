<template>
  <div class="panel content overflow-x-auto">
    <h2 class="tw-section-title">Record number</h2>
    <div class="flex-wrap-column middle align-start full_width">
      <div class="separate-right full_width">
        <div
          v-if="store.identifiers > 1"
          class="separate-bottom"
        >
          <IconWarning class="w-4 h-4 text-warning-color" />
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
                <div class="w-full horizontal-right-content">
                  <VLock v-model="settings.locked.recordNumber" />
                </div>
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
            <div
              class="middle flex-separate gap-small padding-medium-top padding-medium-bottom"
            >
              <span v-html="namespace.name" />
              <VBtn
                v-if="store.identifier.id"
                color="destroy"
                icon
                variant="tonal"
                @click="store.remove"
              >
                <IconTrash class="w-4 h-4" />
              </VBtn>
              <VBtn
                v-else
                color="primary"
                icon
                variant="tonal"
                @click="() => (store.identifier.namespaceId = id)"
              >
                <IconTrash class="w-4 h-4" />
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
            :class="{ 'validate-identifier': store.existingIdentifiers.length }"
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

          <IconWarning
            v-if="
              store.identifier.namespaceId &&
              !store.identifier.identifier?.length
            "
            class="w-4 h-4 text-warning-color margin-small-left"
            v-tooltip="'Namespace and identifier needs to be set to be saved.'"
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
        <ExistingIdentifier
          :existing-identifiers="store.existingIdentifiers"
          @load="confirmAndLoad"
        />
      </div>
    </div>
  </div>
  <ConfirmationModal ref="confirmationModalRef" />
</template>

<script setup>
import { useIdentifierStore } from '../../store/pinia/identifiers.js'
import { computed, ref, watch } from 'vue'
import { useStore } from 'vuex'
import { Namespace } from '@/routes/endpoints'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions.js'
import { IDENTIFIER_LOCAL_RECORD_NUMBER } from '@/constants/index.js'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VLock from '@/components/ui/VLock/index.vue'
import WidgetNamespace from '@/components/ui/Widget/WidgetNamespace.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import ExistingIdentifier from '../shared/ExistingIdentifier.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'
import IconWarning from '@/components/Icon/IconWarning.vue'
import { vTooltip } from '@/directives/tooltip.js'

const store = useIdentifierStore(IDENTIFIER_LOCAL_RECORD_NUMBER)()
const coStore = useStore()
const namespace = ref(null)
const smartSelectorRef = ref()
const widgetNamespaceRef = ref()
const confirmationModalRef = ref()

const DELAY = 1000
let checkRequest = undefined

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
  clearTimeout(checkRequest)

  if (store.identifier.identifier) {
    checkRequest = setTimeout(store.checkExistingIdentifiers, DELAY)
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

async function confirmAndLoad(collectionObjectId) {
  const ok = await confirmationModalRef.value.show({
    title: 'Load collection object',
    message:
      'Loading will discard unsaved changes in the current form. Continue?',
    okButton: 'Load',
    cancelButton: 'Cancel',
    typeButton: 'submit'
  })

  if (ok) {
    coStore.dispatch(ActionNames.ResetWithDefault)
    coStore.dispatch(ActionNames.LoadDigitalization, collectionObjectId)
  }
}
</script>

<style scoped>
.validate-identifier {
  border: 1px solid red;
}
</style>
