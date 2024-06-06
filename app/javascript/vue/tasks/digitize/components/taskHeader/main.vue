<template>
  <nav-bar style="z-index: 1001">
    <div
      id="comprehensive-navbar"
      class="flex-separate"
    >
      <div class="horizontal-left-content">
        <autocomplete
          class="separate-right"
          url="/collection_objects/autocomplete"
          placeholder="Search"
          label="label_html"
          param="term"
          clear-after
          min="1"
          @get-item="(item) => loadAssessionCode(item.id)"
        />
        <soft-validation
          v-if="collectionObject.id"
          class="margin-small-left margin-small-right"
        />
        <a
          class="separate-left"
          v-if="collectionObject.id"
          :href="`/tasks/collection_objects/browse?collection_object_id=${collectionObject.id}`"
          v-html="collectionObject.object_tag"
        />
        <span v-else>New record</span>
      </div>
      <div class="horizontal-left-content">
        <div
          class="margin-medium-right horizontal-left-content"
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
          <div
            class="medium-icon separate-right"
            data-icon="warning"
          />
        </tippy>
        <recent-component
          class="separate-right margin-small-left"
          @selected="loadCollectionObject($event)"
        />
        <button
          type="button"
          class="button normal-input button-submit separate-right"
          @click="saveDigitalization"
        >
          Save
        </button>
        <button
          type="button"
          class="button normal-input button-submit separate-right"
          @click="saveAndNew"
        >
          Save and new
        </button>
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
  </nav-bar>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useStore } from 'vuex'
import { Tippy } from 'vue-tippy'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions.js'
import { GetterNames } from '../../store/getters/getters.js'
import useHotkey from 'vue3-hotkey'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import RecentComponent from './recent.vue'
import platformKey from '@/helpers/getPlatformKey.js'
import Autocomplete from '@/components/ui/Autocomplete.vue'
import NavBar from '@/components/layout/NavBar'
import AjaxCall from '@/helpers/ajaxCall'
import SoftValidation from './softValidation'

const MAX_CO_LIMIT = 100

const store = useStore()

const confirmationModalRef = ref(null)
const shortcuts = ref([
  {
    keys: [platformKey(), 's'],
    handler() {
      saveDigitalization()
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
const collectingEvent = computed(
  () => store.getters[GetterNames.GetCollectingEvent]
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
  () => settings.value.lastChange > settings.value.lastSave
)

const underThreshold = computed(
  () => store.getters[GetterNames.GetCETotalUsed] < MAX_CO_LIMIT
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

watch(
  collectingEvent,
  () => {
    settings.value.lastChange = Date.now()
  },
  { deep: true }
)

async function saveDigitalization() {
  const ok =
    underThreshold.value ||
    !collectingEvent.value.isUpdated ||
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
</style>
