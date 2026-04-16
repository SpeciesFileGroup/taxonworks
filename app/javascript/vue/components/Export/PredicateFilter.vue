<template>
  <div>
    <VSpinner
      v-if="isLoading"
      legend="Loading predicates..."
    />
    <div>
      <VBtn
        class="margin-small-right"
        color="primary"
        medium
        @click="
          () => {
            collectionObjectPredicateId =
              collectionObjectPredicates.map((co) => co.id)
            collectingEventPredicateId =
              collectingEventPredicates.map((ce) => ce.id)
            taxonworksExtensionMethods = [
              ...extensionMethodNames
            ]
          }
        "
      >
        Select all
      </VBtn>
      <VBtn
        color="primary"
        medium
        @click="
          () => {
            collectionObjectPredicateId = []
            collectingEventPredicateId = []
            taxonworksExtensionMethods = []
          }
        "
      >
        Unselect all
      </VBtn>
    </div>
    <div class="margin-small-bottom dwc-download-predicates">
      <div>
        <table v-if="collectingEventPredicates.length">
          <thead>
            <tr>
              <th>
                <input
                  v-model="checkAllCe"
                  type="checkbox"
                />
              </th>
              <th class="full_width">Collecting events</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="item in collectingEventPredicates"
              :key="item.id"
            >
              <td>
                <input
                  type="checkbox"
                  :value="item.id"
                  v-model="collectingEventPredicateId"
                />
              </td>
              <td>
                <span v-html="item.object_tag" />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div>
        <table v-if="collectionObjectPredicates.length">
          <thead>
            <tr>
              <th>
                <input
                  v-model="checkAllCo"
                  type="checkbox"
                />
              </th>
              <th class="full_width">Collection objects</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="item in collectionObjectPredicates"
              :key="item.id"
            >
              <td>
                <input
                  type="checkbox"
                  :value="item.id"
                  v-model="collectionObjectPredicateId"
                />
              </td>
              <td>
                <span v-html="item.object_tag" />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div>
        <table v-if="extensionMethodNames.length">
          <thead>
            <tr>
              <th>
                <input
                  v-model="checkAllExtensionMethods"
                  type="checkbox"
                />
              </th>
              <th class="full_width">Internal values</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="item in extensionMethodNames"
              :key="item.id"
            >
              <td>
                <input
                  type="checkbox"
                  :value="item"
                  v-model="taxonworksExtensionMethods"
                />
              </td>
              <td>
                <span v-html="item" />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onBeforeMount, ref } from 'vue'
import { DwcOcurrence } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const collectingEventPredicates = ref([])
const collectionObjectPredicates = ref([])
const extensionMethodNames = ref([])
const isLoading = ref(false)

const collectingEventPredicateId = defineModel('collectingEventPredicateId', {
  type: Array,
  required: true
})

const collectionObjectPredicateId = defineModel('collectionObjectPredicateId', {
  type: Array,
  required: true
})

const taxonworksExtensionMethods = defineModel('taxonworksExtensionMethods', {
  type: Array,
  required: true
})

onBeforeMount(async () => {
  try {
    isLoading.value = true

    const [predicates, extensions] = await Promise.all([
      DwcOcurrence.predicates(),
      DwcOcurrence.taxonworksExtensionMethods()
    ])

    collectingEventPredicates.value = predicates.body.collecting_event
    collectionObjectPredicates.value = predicates.body.collection_object
    extensionMethodNames.value = extensions.body
    predicatesLoaded.value = true
  } catch (e) {}

  isLoading.value = false
})

const checkAllCe = computed({
  get: () =>
    collectingEventPredicateId.value.length ===
    collectingEventPredicates.value.length,
  set: (isChecked) => {
    collectingEventPredicateId.value = isChecked
      ? collectingEventPredicates.value.map((ce) => ce.id)
      : []
  }
})

const checkAllCo = computed({
  get: () =>
    collectionObjectPredicateId.value.length ===
    collectionObjectPredicates.value.length,
  set: (isChecked) => {
    collectionObjectPredicateId.value = isChecked
      ? collectionObjectPredicates.value.map((co) => co.id)
      : []
  }
})

const checkAllExtensionMethods = computed({
  get: () =>
    taxonworksExtensionMethods.value.length ===
    extensionMethodNames.value.length,
  set: (isChecked) => {
    taxonworksExtensionMethods.value = isChecked
      ? extensionMethodNames.value
      : []
  }
})

</script>