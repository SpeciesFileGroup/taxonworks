<template>
  <BlockLayout>
    <template #header>
      <h3>Depict some</h3>
    </template>
    <template #body>
      <ul class="no_bullets">
        <li
          v-for="item in OBJECT_TYPES"
          :key="item.type"
        >
          <label>
            <input
              v-model="selectedType"
              type="radio"
              name="depicsome"
              :value="item"
            />
            {{ item.label }}
          </label>
        </li>
      </ul>
      <OtuAutoselectPicker
        v-if="isOtuType"
        class="margin-medium-top"
        preferences-key="otu_for_new_image_depic_some"
        @get-item="addToList"
      />
      <SmartSelector
        v-else-if="selectedType"
        class="margin-medium-top"
        :model="selectedType.model"
        :klass="selectedType.type"
        target="Depiction"
        @selected="addToList"
      />

      <TableList
        v-if="listCreated.length"
        class="margin-medium-top"
        :list="listCreated"
        :header="['Objects', '']"
        :delete-warning="false"
        soft-delete
        annotator
        navigator
        quick-forms
        :attributes="['label']"
        @delete="
          (item) => store.commit(MutationNames.RemoveObjectForDepictions, item)
        "
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import SmartSelector from '@/components/ui/SmartSelector'
import OtuAutoselectPicker from '@/components/otu/otu_picker/otu_autoselect_picker.vue'
import TableList from '@/components/table_list'

import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import {
  OTU,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  FIELD_OCCURRENCE
} from '@/constants'

const store = useStore()

const listCreated = computed(
  () => store.getters[GetterNames.GetObjectsForDepictions]
)
const isOtuType = computed(() => selectedType.value?.type === OTU)

const OBJECT_TYPES = [
  {
    type: OTU,
    label: 'Otu',
    model: 'otus'
  },
  {
    type: COLLECTING_EVENT,
    label: 'Collecting event',
    model: 'collecting_events'
  },
  {
    type: COLLECTION_OBJECT,
    label: 'Collection object',
    model: 'collection_objects'
  },
  {
    type: FIELD_OCCURRENCE,
    label: 'Field occurrence',
    model: 'field_occurrences'
  },
  {
    type: 'Person',
    label: 'Person',
    model: 'people'
  }
]
const selectedType = ref()

function addToList(item) {
  store.commit(MutationNames.AddObjectForDepictions, {
    id: item.id,
    label: item.object_label,
    global_id: item.global_id,
    base_class: selectedType.value.type
  })
}
</script>
