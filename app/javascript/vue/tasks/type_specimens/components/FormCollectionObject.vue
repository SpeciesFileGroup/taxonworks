<template>
  <div>
    <div class="field label-above">
      <label>Buffered collecting event</label>
      <textarea
        class="full_width"
        rows="5"
        v-model="store.typeMaterial.collectionObject.bufferedCollectingEvent"
        @change="() => (store.typeMaterial.isUnsaved = true)"
      />
    </div>
    <div class="field label-above">
      <label>Buffered determinations</label>
      <textarea
        class="full_width"
        rows="5"
        v-model="store.typeMaterial.collectionObject.bufferedDeterminations"
        @change="() => (store.typeMaterial.isUnsaved = true)"
      />
    </div>
    <div class="field label-above">
      <label>Buffered other labels</label>
      <textarea
        class="full_width"
        rows="5"
        v-model="store.typeMaterial.collectionObject.bufferedOtherLabels"
        @change="() => (store.typeMaterial.isUnsaved = true)"
      />
    </div>
    <div class="horizontal-left-content">
      <div class="field label-above">
        <label>Total</label>
        <input
          class="input-xsmall-width"
          type="number"
          v-model="store.typeMaterial.collectionObject.total"
          @change="() => (store.typeMaterial.isUnsaved = true)"
        />
      </div>
      <div class="field label-above margin-small-left full_width">
        <label>Preparation type</label>
        <select
          v-model="store.typeMaterial.collectionObject.preparationTypeId"
          class="normal-input full_width"
          @change="() => (store.typeMaterial.isUnsaved = true)"
        >
          <option
            v-for="item in preparationTypes"
            :key="item.id"
            class="full_width"
            :value="item.id"
          >
            {{ item.name }}
          </option>
        </select>
      </div>
    </div>
    <div class="field">
      <fieldset>
        <legend>Repository</legend>
        <SmartSelector
          class="full_width"
          model="repositories"
          target="CollectionObject"
          klass="CollectionObject"
          pin-section="Repositories"
          pin-type="Repository"
          @selected="
            ({ id }) => {
              store.typeMaterial.collectionObject.repositoryId = id
              store.typeMaterial.isUnsaved = true
            }
          "
        >
          <template #tabs-right>
            <a
              href="/repositories/new"
              target="_blank"
              >New</a
            >
          </template>
        </SmartSelector>

        <SmartSelectorItem
          :item="labelRepository"
          :label="false"
          @unset="
            () => {
              store.typeMaterial.collectionObject.repositoryId = null
              store.typeMaterial.isUnsaved = true
            }
          "
        />
      </fieldset>
    </div>
    <div class="field">
      <fieldset>
        <legend>Collecting event</legend>
        <SmartSelector
          model="collecting_events"
          klass="CollectionObject"
          pin-section="CollectingEvents"
          pin-type="CollectingEvent"
          @selected="
            ({ id }) => {
              store.typeMaterial.collectionObject.collectingEventId = id
              store.typeMaterial.isUnsaved = true
            }
          "
        />

        <SmartSelectorItem
          :item="labelCE"
          :label="false"
          @unset="
            () => {
              store.typeMaterial.collectionObject.collectingEventId = null
              store.typeMaterial.isUnsaved = true
            }
          "
        />
      </fieldset>
    </div>

    <div class="field">
      <FormBiocurations />
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import FormBiocurations from './Biocurations.vue'
import useStore from '../store/store.js'
import {
  CollectingEvent,
  Repository,
  PreparationType
} from '@/routes/endpoints'

const store = useStore()
const preparationTypes = ref([])
const labelRepository = ref('')
const labelCE = ref('')

PreparationType.all().then(({ body }) => {
  preparationTypes.value = body
})

const collectingEventId = computed(
  () => store.typeMaterial.collectionObject.collectingEventId
)
const repositoryId = computed(
  () => store.typeMaterial.collectionObject.repositoryId
)

watch(collectingEventId, (id) => {
  if (id) {
    CollectingEvent.find(id).then(({ body }) => {
      labelCE.value = body.cached
    })
  } else {
    labelCE.value = ''
  }
})

watch(repositoryId, (id) => {
  if (id) {
    Repository.find(id).then(({ body }) => {
      labelRepository.value = body.name
    })
  } else {
    labelRepository.value = ''
  }
})
</script>
