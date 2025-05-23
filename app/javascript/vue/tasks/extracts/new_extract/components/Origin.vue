<template>
  <BlockLayout>
    <template #header>
      <h3>Origin</h3>
    </template>
    <template #body>
      <div>
        <template v-if="!originRelationship.old_object_id">
          <div class="horizontal-left-content middle margin-small-bottom">
            <SwitchComponent
              v-model="tabSelected"
              :options="Object.keys(smartTypes)"
            />
            <LockComponent
              class="margin-small-left"
              v-model="settings.lock.originRelationships"
            />
          </div>

          <SmartSelector
            :model="smartTypes[tabSelected]"
            klass="Extract"
            target="Extract"
            @selected="setOrigin"
          />
        </template>

        <div
          v-if="originRelationship.label"
          class="horizontal-left-content"
        >
          <span v-html="originRelationship.label" />
          <button
            class="button circle-button btn-undo button-default"
            type="button"
            @click="
              store.commit(
                MutationNames.SetOriginRelationship,
                makeOriginRelationship()
              )
            "
          />
          <LockComponent
            class="margin-small-left"
            v-model="settings.lock.originRelationship"
          />
        </div>

        <div
          v-if="!isExtract"
          class="field label-above margin-medium-top"
        >
          <label>Verbatim anatomical origin</label>
          <input
            type="text"
            v-model="extract.verbatim_anatomical_origin"
          />
        </div>

        <VBtn
          color="primary"
          medium
          @click="addOriginToList"
        >
          Add
        </VBtn>

        <DisplayList
          :list="list"
          label="label"
          soft-delete
          :warning="false"
          @delete="removeOriginRelationship"
        />
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector'
import SwitchComponent from '@/components/ui/VSwitch'
import LockComponent from '@/components/ui/VLock/index.vue'
import BlockLayout from '@/components/layout/BlockLayout'
import useSettings from '../composables/useSettings.js'
import useExtract from '../composables/useExtract.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import DisplayList from '@/components/displayList.vue'
import makeOriginRelationship from '../helpers/makeOriginRelationship'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import { CollectionObject, Extract, Otu } from '@/routes/endpoints'
import { COLLECTION_OBJECT, EXTRACT, OTU } from '@/constants/index.js'
import { ref, computed, watch, onBeforeMount } from 'vue'
import { useStore } from 'vuex'
import { URLParamsToJSON } from '@/helpers'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams.js'

const smartTypes = {
  [COLLECTION_OBJECT]: 'collection_objects',
  [EXTRACT]: 'extracts',
  [OTU]: 'otus'
}

const services = {
  CollectionObject,
  Extract,
  Otu
}
const store = useStore()

const tabSelected = ref(COLLECTION_OBJECT)
const settings = useSettings()
const extract = useExtract()

const isExtract = computed(() => tabSelected.value === EXTRACT)
const list = computed(() => store.getters[GetterNames.GetOriginRelationships])

const originRelationship = computed({
  get: () => store.getters[GetterNames.GetOriginRelationship],
  set: (value) => store.commit(MutationNames.SetOriginRelationship, value)
})

watch(
  () => isExtract.value,
  (newVal) => {
    if (newVal) {
      extract.value.verbatim_anatomical_origin = undefined
    }
  }
)

watch(
  () => originRelationship.value,
  ({ old_object_type }) => {
    if (old_object_type) {
      tabSelected.value = old_object_type
    }
  }
)

onBeforeMount(() => {
  const params = URLParamsToJSON(location.href)
  const entry = Object.entries(ID_PARAM_FOR).find(
    ([type, param]) => params[param]
  )

  if (entry) {
    const [objectType, param] = entry

    const value = params[param]

    services[objectType]
      .find(value)
      .then(({ body }) => {
        if (body) {
          setOrigin(body)
          addOriginToList()
        }
      })
      .catch(() => {})
  }
})

function setOrigin({ base_class, id, object_tag }) {
  store.commit(MutationNames.SetOriginRelationship, {
    ...originRelationship.value,
    label: object_tag,
    old_object_id: id,
    old_object_type: base_class || COLLECTION_OBJECT,
    isUnsaved: true
  })
}

function addOriginToList() {
  store.commit(MutationNames.AddOriginToList, originRelationship.value)
  store.commit(MutationNames.SetOriginRelationship, makeOriginRelationship())
}

function removeOriginRelationship(relationship) {
  store.dispatch(ActionNames.RemoveOriginRelationship, relationship)
}
</script>
