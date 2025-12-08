<template>
  <NavBar
    style="z-index: 1001"
    :navbar-class="`panel content ${
      collectionObject?.dwc_occurrence?.rebuild_set
        ? 'pending-dwc-regeneration'
        : ''
    }`"
  >
    <div
      id="comprehensive-navbar"
      class="flex-separate"
    >
      <div class="horizontal-left-content gap-small">
        <VAutocomplete
          url="/collection_objects/autocomplete"
          placeholder="Search"
          label="label_html"
          param="term"
          clear-after
          min="1"
          @get-item="(item) => loadAssessionCode(item.id)"
        />
        <template v-if="collectionObject.id">
          <SoftValidation v-if="collectionObject.id" />
          <a
            :href="`${RouteNames.BrowseCollectionObject}?collection_object_id=${collectionObject.id}`"
            v-html="collectionObject.object_tag"
          />
          <div
            v-if="collectionObject?.dwc_occurrence?.rebuild_set"
            class="horizontal-left-content gap-small middle text-warning-color"
          >
            <VIcon
              name="attention"
              small
              color="warning"
            />
            DwcOccurrence re-index is pending.
          </div>
        </template>
        <span v-else>New record</span>
      </div>
      <div class="horizontal-left-content gap-small middle">
        <div
          class="horizontal-left-content"
          v-if="collectionObject.id"
        >
          <ul class="context-menu no_bullets">
            <li>
              <span
                v-if="navigation.previous"
                @click="loadAssessionCode(navigation.previous)"
                class="link cursor-pointer horizontal-right-content"
                >‹ Id</span
              >
              <span
                v-else
                class="horizontal-right-content"
                >‹ Id
              </span>
              <span
                v-if="navigation.previousIdentifier"
                @click="loadAssessionCode(navigation.previousIdentifier)"
                class="link cursor-pointer horizontal-right-content"
                >‹ Identifier</span
              >
              <span v-else>‹ Identifier</span>
            </li>
            <li>
              <span
                v-if="navigation.next"
                @click="loadAssessionCode(navigation.next)"
                class="link cursor-pointer horizontal-left-content"
                >Id ›</span
              >
              <span
                v-else
                class="horizontal-left-content"
                >Id ›</span
              >
              <span
                v-if="navigation.nextIdentifier"
                @click="loadAssessionCode(navigation.nextIdentifier)"
                class="link cursor-pointer horizontal-left-content"
                >Identifier ›</span
              >
              <span v-else>Identifier ›</span>
            </li>
          </ul>
        </div>
        <tippy
          v-if="hasChanges"
          animation="scale"
          placement="bottom"
          size="small"
          inertia
          arrow
        >
          <template #content>
            <p>You have unsaved changes.</p>
          </template>
          <VIcon
            name="attention"
            color="attention"
            title="You have unsaved changes."
            small
          />
        </tippy>
        <RecentComponent @selected="loadCollectionObject($event)" />
        <VBtn
          medium
          color="create"
          @click="saveDigitalization"
        >
          Save
        </VBtn>
        <VBtn
          medium
          color="create"
          @click="saveAndNew"
        >
          Save and new
        </VBtn>
        <div
          class="cursor-pointer"
          @click="resetStore"
        >
          <span data-icon="reset" />
          <span>Reset</span>
        </div>
      </div>
      <ConfirmationModal ref="confirmationModalRef" />
    </div>
  </NavBar>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useStore } from 'vuex'
import { Tippy } from 'vue-tippy'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions.js'
import { GetterNames } from '../../store/getters/getters.js'
import { useHotkey } from '@/composables'
import { RouteNames } from '@/routes/routes.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import RecentComponent from './recent.vue'
import platformKey from '@/helpers/getPlatformKey.js'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import NavBar from '@/components/layout/NavBar'
import AjaxCall from '@/helpers/ajaxCall'
import SoftValidation from './softValidation'
import VIcon from '@/components/ui/VIcon/index.vue'
import useCollectingEventStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'
import useBiologicalAssociationStore from '@/components/Form/FormBiologicalAssociation/store/biologicalAssociations.js'
import useBiocurationStore from '@/tasks/field_occurrences/new/store/biocurations.js'

const MAX_CO_LIMIT = 100

const store = useStore()
const collectingEventStore = useCollectingEventStore()
const biologicalAssociationStore = useBiologicalAssociationStore()
const biocurationStore = useBiocurationStore()

const confirmationModalRef = ref(null)
const shortcuts = ref([
  {
    keys: [platformKey(), 's'],
    handler() {
      if (!settings.value.loading && !settings.value.saving) {
        saveDigitalization()
      }
    }
  },
  {
    keys: [platformKey(), 'n'],
    handler() {
      saveAndNew()
    }
  },
  {
    keys: [platformKey(), 'r'],
    handler() {
      resetStore()
    }
  }
])

useHotkey(shortcuts.value)

const collectionObject = computed(
  () => store.getters[GetterNames.GetCollectionObject]
)

const settings = computed({
  get() {
    return store.getters[GetterNames.GetSettings]
  },
  set(value) {
    store.commit(MutationNames.SetSettings, value)
  }
})

const hasChanges = computed(
  () =>
    settings.value.lastChange > settings.value.lastSave ||
    collectingEventStore.isUnsaved ||
    biologicalAssociationStore.hasUnsaved ||
    biocurationStore.hasUnsaved
)

const underThreshold = computed(
  () => collectingEventStore.totalUsed < MAX_CO_LIMIT
)

const loadingNavigation = ref(false)
const navigation = ref({
  next: undefined,
  previous: undefined
})

watch(
  collectionObject,
  (newVal, oldVal) => {
    settings.value.lastChange = Date.now()
    if (newVal.id && oldVal.id != newVal.id) {
      if (!loadingNavigation.value) {
        loadingNavigation.value = true
        AjaxCall(
          'get',
          `/metadata/object_navigation/${encodeURIComponent(newVal.global_id)}`
        ).then(({ headers }) => {
          navigation.value = {
            next: headers['navigation-next'],
            nextIdentifier: headers['navigation-next-by-identifier'],
            previous: headers['navigation-previous'],
            previousIdentifier: headers['navigation-previous-by-identifier']
          }

          loadingNavigation.value = false
        })
      }
    }
  },
  { deep: true }
)

async function saveDigitalization() {
  const ok =
    underThreshold.value ||
    collectingEventStore.isUnsaved ||
    (await confirmationModalRef.value.show({
      title: 'Save',
      message: `The collecting event was modified and is used by over ${MAX_CO_LIMIT}. Are you sure you want to proceed?`,
      okButton: 'Save',
      cancelButton: 'Cancel',
      typeButton: 'submit'
    }))

  if (ok) {
    if (!settings.value.saving) {
      store.dispatch(ActionNames.SaveDigitalization)
    }
  }
}

function resetStore() {
  store.dispatch(ActionNames.ResetStore)
}

function saveAndNew() {
  if (!settings.value.saving) {
    store.dispatch(ActionNames.SaveDigitalization, {
      resetAfter: true
    })
  }
}

function loadAssessionCode(id) {
  store.dispatch(ActionNames.ResetWithDefault)
  store.dispatch(ActionNames.LoadDigitalization, id)
}

function loadCollectionObject(co) {
  resetStore()
  store.dispatch(ActionNames.LoadDigitalization, co.id)
}

</script>

<style lang="scss" scoped>
.fixed-bar {
  position: fixed;
  top: 0px;
  width: calc(100% - 52px);
  z-index: 200;
}

:deep(.pending-dwc-regeneration) {
  outline: 2px solid var(--color-attention);
  outline-offset: -2px;
}
</style>
