<template>
  <div class="flexbox align-start">
    <BlockLayout :warning="!collectionObject.id">
      <template #header>
        <h3>Collection Object</h3>
      </template>
      <template #options>
        <div
          v-if="collectionObject.id"
          class="horizontal-left-content gap-small"
        >
          <RadialAnnotator :global-id="collectionObject.global_id" />
          <ButtonTag :global-id="collectionObject.global_id" />
          <RadialObject :global-id="collectionObject.global_id" />
          <RadialNavigation :global-id="collectionObject.global_id" />
        </div>
      </template>
      <template #body>
        <div id="collection-object-form">
          <CatalogueNumber
            v-if="
              !layout[COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_CATALOG_NUMBER]
            "
            class="panel content"
          />
          <RepositoryComponent
            v-if="!layout[COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_REPOSITORY]"
            class="panel content"
          />
          <PreparationType
            v-if="!layout[COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_PREPARATION]"
            class="panel content"
          />
          <div
            v-if="!layout[COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_BUFFERED]"
            class="panel content"
          >
            <h2 class="flex-separate">Buffered</h2>
            <BufferedComponent class="field" />
          </div>
          <div
            v-if="!layout[COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_DEPICTIONS]"
            class="panel content column-depictions"
          >
            <h2 class="flex-separate">Depictions</h2>
            <DepictionsComponent
              :object-value="collectionObject"
              object-type="CollectionObject"
              default-message="Drop images or click here<br> to add collection object figures"
              action-save="SaveCollectionObject"
              @create="createDepictionForAll"
              @delete="removeAllDepictionsByImageId"
            />
          </div>
          <SoftValidations
            v-if="!layout[COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_VALIDATIONS]"
            class="column-validation"
            :validations="validations"
          />
          <div
            v-if="!layout[COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_CITATIONS]"
            class="panel content column-citations"
          >
            <h2 class="flex-separate">Citations</h2>
            <CitationComponent />
          </div>
          <div
            v-if="!layout[COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_ATTRIBUTES]"
            class="panel content column-attribute"
          >
            <h2 class="flex-separate">Attributes</h2>
            <div>
              <VSpinner
                v-if="!collectionObject.id"
                :show-spinner="false"
                :legend-style="{
                  color: '#444',
                  textAlign: 'center'
                }"
                legend="Locked until first save"
              />
              <PredicatesComponent />
            </div>
          </div>
          <ContainerItems class="row-item" />
        </div>
      </template>
    </BlockLayout>
  </div>
</template>

<script setup>
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions'
import { Depiction } from '@/routes/endpoints'
import { COLLECTION_OBJECT } from '@/constants/index.js'
import {
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_CITATIONS,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_ATTRIBUTES,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_BUFFERED,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_DEPICTIONS,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_PREPARATION,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_REPOSITORY,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_CATALOG_NUMBER,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_VALIDATIONS
} from '@/tasks/digitize/const/layout'
import { computed, ref, watch } from 'vue'
import { useStore } from 'vuex'

import VSpinner from '@/components/ui/VSpinner'
import ContainerItems from './containerItems.vue'
import PreparationType from './preparationType.vue'
import CatalogueNumber from '../catalogueNumber/catalogNumber.vue'
import BufferedComponent from './bufferedData.vue'
import DepictionsComponent from '../shared/depictions.vue'
import RepositoryComponent from './Repository/main.vue'
import CitationComponent from './Citation/CitationMain.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigation from '@/components/radials/navigation/radial.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import PredicatesComponent from './predicates.vue'
import ButtonTag from '@/components/ui/Button/ButtonTag.vue'
import platformKey from '@/helpers/getPlatformKey'
import SoftValidations from '@/components/soft_validations/panel.vue'
import useHotkey from 'vue3-hotkey'

const store = useStore()

const shortcuts = ref([
  {
    keys: [platformKey(), 'e'],
    handler() {
      openBrowse
    }
  }
])

useHotkey(shortcuts.value)

const collectionObject = computed({
  get() {
    return store.getters[GetterNames.GetCollectionObject]
  },
  set(value) {
    store.commit(MutationNames.SetCollectionObject, value)
  }
})

const collectionObjects = computed(
  () => store.getters[GetterNames.GetCollectionObjects]
)

const depictions = computed({
  get() {
    return store.getters[GetterNames.GetDepictions]
  },
  set(value) {
    store.commit(MutationNames.SetDepictions, value)
  }
})

const validations = computed(() => {
  const { Specimen } = store.getters[GetterNames.GetSoftValidations]

  return Specimen ? { Specimen } : {}
})

const layout = computed(
  () => store.getters[GetterNames.GetPreferences]?.layout || {}
)

watch(collectionObject, (newVal) => {
  if (newVal.id) {
    cloneDepictions(newVal)
  }
})

function cloneDepictions(co) {
  const unique = new Set()
  const depictionsRemovedDuplicate = depictions.value.filter((depiction) => {
    const key = depiction.image_id
    const isNew = !unique.has(key)

    if (isNew) unique.add(key)
    return isNew
  })

  const coDepictions = depictions.value.filter(
    (depiction) => depiction.depiction_object_id === co.id
  )

  depictionsRemovedDuplicate.forEach((depiction) => {
    if (!coDepictions.find((item) => item.image_id === depiction.image_id)) {
      saveDepiction(co.id, depiction)
    }
  })
}

function saveDepiction(coId, data) {
  const payload = {
    depiction: {
      depiction_object_id: coId,
      depiction_object_type: COLLECTION_OBJECT,
      image_id: data.image_id
    }
  }

  Depiction.create(payload).then(({ body }) => {
    depictions.value.push(body)
  })
}

function createDepictionForAll(depiction) {
  const coIds = collectionObjects.value
    .map((co) => co.id)
    .filter((id) => collectionObject.value.id !== id)

  depictions.value.push(depiction)
  coIds.forEach((id) => {
    saveDepiction(id, depiction)
  })
}

function removeAllDepictionsByImageId(depiction) {
  store.dispatch(ActionNames.RemoveDepictionsByImageId, depiction)
}

function openBrowse() {
  if (collectionObject.value.id) {
    window.open(
      `/tasks/collection_objects/browse?collection_object_id=${collectionObject.value.id}`,
      '_self'
    )
  }
}
</script>

<style scoped>
#collection-object-form {
  display: grid;
  grid-template-columns: repeat(3, minmax(250px, 1fr));
  gap: 0.5em;
  grid-auto-flow: dense;
}

.depict-validation-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 0.5em;
}

.column-validation {
  grid-column: 3 / 4;
}

.row-1-3 {
  grid-column: 1 / 3;
}
.row-item {
  grid-column: 1 / 4;
}
</style>
