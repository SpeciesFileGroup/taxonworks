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
      v-if="showModal">
      <template #header>
        <h3>Download DwC</h3>
      </template>
      <template #body>
        <h4>Filter by predicates</h4>
        <div class="margin-small-bottom">
          <div v-if="collectingEvents.length">
            <p>Collecting events</p>
            <ul class="no_bullets">
              <li
                v-for="item in collectingEvents"
                :key="item.id">
                <label>
                  <input
                    type="checkbox"
                    :value="item.id"
                    v-model="predicateParams.collecting_event_predicate_id">
                  <span v-html="item.object_tag"/>
                </label>
              </li>
            </ul>
          </div>
          <div v-if="collectionObjects.length">
            <p>Collection objects</p>
            <ul class="no_bullets">
              <li v-for="item in collectionObjects">
                <label>
                  <input
                    type="checkbox"
                    :value="item.id"
                    v-model="predicateParams.collection_object_predicate_id">
                  <span v-html="item.object_tag"/>
                </label>
              </li>
            </ul>
          </div>
        </div>
      </template>
      <template #footer>
        <v-btn
          color="create"
          medium
          @click="download"
        >
          Download
        </v-btn>
      </template>
    </v-modal>
  </div>
</template>
<script setup>

import { reactive, ref, onBeforeMount } from 'vue'
import { RouteNames } from 'routes/routes.js'
import { DwcOcurrence } from 'routes/endpoints'
import { transformObjectToParams } from 'helpers/setParam.js'
import VBtn from 'components/ui/VBtn/index.vue'
import VModal from 'components/ui/Modal.vue'

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
const collectingEvents = ref([])
const collectionObjects = ref([])
const predicateParams = reactive({
  collecting_event_predicate_id: [],
  collection_object_predicate_id: []
})

const getFilterParams = params => {
  const entries = Object.entries({...params, ...predicateParams }).filter(([key, value]) => !Array.isArray(value) || value.length)
  const data = Object.fromEntries(entries)

  data.per = props.total
  delete data.page

  return data
}

const download = () => {
  const downloadParams = getFilterParams(props.params)

  DwcOcurrence.generateDownload({ ...downloadParams }).then(_ => {
    window.open(`${RouteNames.DwcDashboard}?${transformObjectToParams(downloadParams)}`)
    setModalView(false)
  })
}

const setModalView = value => { showModal.value = value }

onBeforeMount(() => {
  DwcOcurrence.predicates().then(({ body }) => {
    collectingEvents.value = body.collecting_event
    collectionObjects.value = body.collection_object
  })
})
</script>
