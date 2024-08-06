<template>
  <div>
    <modal
      v-if="isModalVisible"
      @close="() => (isModalVisible = false)"
    >
      <template #header>
        <h3>Confirm</h3>
      </template>
      <template #body>
        <div>
          Are you sure you want to create a new taxon name? All unsaved changes
          will be lost.
        </div>
      </template>
      <template #footer>
        <button
          id="confirm-create-newtaxonname"
          @click="reloadPage()"
          type="button"
          class="normal-input button button-default"
        >
          New
        </button>
      </template>
    </modal>
    <button
      type="button"
      class="normal-input button button-default"
      @click="createNew()"
    >
      New
    </button>
  </div>
</template>
<script setup>
import { GetterNames } from '../store/getters/getters'
import { RouteNames } from '@/routes/routes'
import { computed, ref, watch, nextTick } from 'vue'
import { useStore } from 'vuex'
import Modal from '@/components/ui/Modal.vue'
import PlatformKey from '@/helpers/getPlatformKey'
import useHotkey from 'vue3-hotkey'

const store = useStore()

const unsavedChanges = computed(
  () =>
    store.getters[GetterNames.GetLastChange] >
    store.getters[GetterNames.GetLastSave]
)

const parent = computed(() => store.getters[GetterNames.GetParent])
const taxon = computed(() => store.getters[GetterNames.GetTaxon])

const shortcuts = ref([
  {
    keys: [PlatformKey(), 'p'],
    preventDefault: true,
    handler() {
      createNewWithParent()
    }
  },
  {
    keys: [PlatformKey(), 'd'],
    preventDefault: true,
    handler() {
      createNewWithChild()
    }
  },
  {
    keys: [PlatformKey(), 'n'],
    preventDefault: true,
    handler() {
      createNew()
    }
  }
])

useHotkey(shortcuts.value)

const isModalVisible = ref(false)
const url = ref(RouteNames.NewTaxonName)

watch(isModalVisible, (newVal) => {
  if (newVal) {
    nextTick(() => {
      document.querySelector('#confirm-create-newtaxonname').focus()
    })
  }
})

function reloadPage() {
  window.location.href = url.value
  url.value = RouteNames.NewTaxonName
}

function loadTask(taxon) {
  return taxon.id
    ? `${RouteNames.NewTaxonName}?parent_id=${taxon.id}`
    : RouteNames.NewTaxonName
}

function createNew(newUrl = url.value) {
  url.value = newUrl
  if (unsavedChanges.value) {
    isModalVisible.value = true
  } else {
    reloadPage()
  }
}

function createNewWithChild() {
  createNew(loadTask(taxon.value))
}

function createNewWithParent() {
  createNew(loadTask(parent.value))
}
</script>
