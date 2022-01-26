<template>
  <div>
    <v-btn
      color="primary"
      medium
      @click="setModalView(true)"
    >
      Download DwC
    </v-btn>
    <v-modal
      @close="setModalView(false)"
      :container-style="{ width: '700px', minHeight: '200px' }"
      v-if="showModal"
    >
      <template #header>
        <h3>Download DwC</h3>
      </template>
      <template #body>
        <v-spinner
          v-if="isLoading"
          legend="Loading predicates..."
        />
        <h3>Filter by predicates</h3>
        <div>
          <v-btn
            class="margin-small-right"
            color="primary"
            medium
            @click="
              predicateParams.collection_object_predicate_id = collectionObjects.map(co => co.id);
              predicateParams.collecting_event_predicate_id = collectingEvents.map(ce => ce.id)
            "
          >
            Select all
          </v-btn>
          <v-btn
            color="primary"
            medium
            @click="
              predicateParams.collection_object_predicate_id = [];
              predicateParams.collecting_event_predicate_id = []
            "
          >
            Unselect all
          </v-btn>
        </div>
        <div class="margin-small-bottom dwc-download-predicates">
          <div>
            <table v-if="collectingEvents.length">
              <thead>
                <tr>
                  <th>
                    <input
                      v-model="checkAllCe"
                      type="checkbox">
                  </th>
                  <th class="full_width">Collecting events</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="item in collectingEvents"
                  :key="item.id">
                  <td>
                    <input
                      type="checkbox"
                      :value="item.id"
                      v-model="predicateParams.collecting_event_predicate_id">
                  </td>
                  <td>
                    <span v-html="item.object_tag" />
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div>
            <table
              v-if="collectionObjects.length">
              <thead>
                <tr>
                  <th>
                    <input
                      v-model="checkAllCo"
                      type="checkbox">
                  </th>
                  <th class="full_width">Collection objects</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="item in collectionObjects"
                  :key="item.id">
                  <td>
                    <input
                      type="checkbox"
                      :value="item.id"
                      v-model="predicateParams.collection_object_predicate_id">
                  </td>
                  <td>
                    <span v-html="item.object_tag" />
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <div class="margin-medium-top">
          <v-btn
            color="create"
            medium
            @click="download"
          >
            Download
          </v-btn>
        </div>
      </template>
    </v-modal>
  </div>
</template>
<script setup>

import { computed, reactive, ref, onBeforeMount, watch } from 'vue'
import { RouteNames } from 'routes/routes.js'
import { DwcOcurrence } from 'routes/endpoints'
import { transformObjectToParams } from 'helpers/setParam.js'
import VBtn from 'components/ui/VBtn/index.vue'
import VModal from 'components/ui/Modal.vue'
import VSpinner from 'components/spinner.vue'

const props = defineProps({
  params: {
    type: Object,
    required: true
  },

  total: {
    type: Number,
    required: true
  }
})

const showModal = ref(false)
const isLoading = ref(false)
const collectingEvents = ref([])
const collectionObjects = ref([])
const predicateParams = reactive({
  collecting_event_predicate_id: [],
  collection_object_predicate_id: []
})

const getFilterParams = params => {
  const entries = Object.entries({ ...params, ...predicateParams }).filter(([key, value]) => !Array.isArray(value) || value.length)
  const data = Object.fromEntries(entries)

  data.per = props.total
  delete data.page

  return data
}

const checkAllCe = computed({
  get: () => predicateParams.collecting_event_predicate_id.length === collectingEvents.value.length,
  set: isChecked => {
    predicateParams.collecting_event_predicate_id = isChecked
      ? collectingEvents.value.map(co => co.id)
      : []
  }
})

const checkAllCo = computed({
  get: () => predicateParams.collection_object_predicate_id.length === collectionObjects.value.length,
  set: isChecked => {
    predicateParams.collection_object_predicate_id = isChecked
      ? collectionObjects.value.map(co => co.id)
      : []
  }
})

const download = () => {
  const downloadParams = getFilterParams(props.params)

  DwcOcurrence.generateDownload({ ...downloadParams }).then(_ => {
    window.open(`${RouteNames.DwcDashboard}?${transformObjectToParams(downloadParams)}`)
    setModalView(false)
  })
}

const setModalView = value => { showModal.value = value }

onBeforeMount(() => {
  isLoading.value = true

  DwcOcurrence.predicates().then(({ body }) => {
    isLoading.value = false
    collectingEvents.value = body.collecting_event
    collectionObjects.value = body.collection_object
  })
})

watch(showModal, newVal => {
  if (newVal) {
    predicateParams.collection_object_predicate_id = []
    predicateParams.collecting_event_predicate_id = []
  }
})

</script>
<style>
  .dwc-download-predicates {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1em;
  }
</style>