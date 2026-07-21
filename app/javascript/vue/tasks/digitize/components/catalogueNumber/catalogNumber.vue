<template>
  <div class="panel content overflow-x-auto">
    <h2 class="tw-section-title">Catalog number</h2>
    <div class="flex-wrap-column middle align-start full_width">
      <div class="separate-right full_width">
        <div
          v-if="store.identifiers.length > 1"
          class="horizontal-left-content gap-small middle"
        >
          <IconWarning class="w-4 h-4 text-warning-color" />
          />
          <span
            >More than one identifier exists! Use annotator to edit
            others.</span
          >
        </div>
        <fieldset>
          <legend>Namespace</legend>
          <div class="horizontal-left-content align-start separate-bottom">
            <SmartSelector
              class="full_width"
              ref="smartSelectorRef"
              model="namespaces"
              input-id="namespace-autocomplete"
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
                <lock-component v-model="locked.identifier" />
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
        <div class="horizontal-left-content field gap-small">
          <input
            id="catalog-number-identifier-field"
            :class="{
              'validate-identifier': store.existingIdentifiers.length
            }"
            type="text"
            v-model="store.identifier.identifier"
            @input="identifierChanged"
          />
          <label>
            <input
              v-model="settings.increment"
              type="checkbox"
            />
            Increment
          </label>
          <IconWarning
            v-if="
              store.identifier.namespaceId &&
              !store.identifier.identifier?.length
            "
            class="w-4 h-4 text-warning-color"
            v-tooltip="'Namespace and identifier needs to be set to be saved.'"
          />
        </div>
        <span
          v-if="
            !store.identifier.namespaceId && store.identifier.identifier?.length
          "
          style="color: red"
          >Namespace is needed.</span
        >
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
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions.js'
import { IDENTIFIER_LOCAL_CATALOG_NUMBER } from '@/constants/index.js'
import { Namespace } from '@/routes/endpoints'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import validateIdentifier from '../../validations/namespace.js'
import LockComponent from '@/components/ui/VLock/index.vue'
import WidgetNamespace from '@/components/ui/Widget/WidgetNamespace.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import ExistingIdentifier from '../shared/ExistingIdentifier.vue'
import IconWarning from '@/components/Icon/IconWarning.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'
import { useIdentifierStore } from '../../store/pinia/identifiers'
import { vTooltip } from '@/directives/tooltip.js'
import { computed, ref, watch } from 'vue'
import { useStore } from 'vuex'

const store = useIdentifierStore(IDENTIFIER_LOCAL_CATALOG_NUMBER)()

const DELAY = 1000
let saveRequest = undefined

const coStore = useStore()
const namespace = ref([])
const widgetNamespaceRef = ref()
const smartSelectorRef = ref()
const confirmationModalRef = ref()

const coId = computed(
  () => coStore.getters[GetterNames.GetCollectionObject]?.id
)

const locked = computed({
  get() {
    return coStore.getters[GetterNames.GetLocked]
  },
  set(value) {
    coStore.commit([MutationNames.SetLocked, value])
  }
})

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

function handleTabChange(tab) {
  if (tab === 'new') {
    widgetNamespaceRef.value.open()
  }
}

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
    typeButton: 'default'
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
