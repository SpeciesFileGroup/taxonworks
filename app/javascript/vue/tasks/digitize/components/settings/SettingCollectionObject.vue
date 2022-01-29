<template>
  <v-btn
    color="primary"
    medium
    @click="showModal = true"
  >
    Layout settings
  </v-btn>
  <v-modal
    v-if="showModal"
    @close="showModal = false"
    :container-style="{ width: '500px' }">
    <template #header>
      <h3>Layout settings</h3>
    </template>
    <template #body>
      <h3>Collection object form</h3>
      <ul class="no_bullets">
        <li
          v-for="(label, key) in LAYOUT_SETTING"
          :key="key">
          <label>
            <input
              :value="preferences[key]"
              :checked="!preferences[key]"
              @click="store.dispatch(ActionNames.UpdateLayoutPreferences, {
                key,
                value: !preferences[key]
              })"
              type="checkbox">
            {{ label }}
          </label>
        </li>
      </ul>
    </template>
  </v-modal>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'
import {
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_CITATIONS,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_ATTRIBUTES,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_BUFFERED,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_DEPICTIONS,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_PREPARATION,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_REPOSITORY,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_CATALOG_NUMBER,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_VALIDATIONS
} from 'tasks/digitize/const/layout'
import VBtn from 'components/ui/VBtn/index.vue'
import VModal from 'components/ui/Modal.vue'

const LAYOUT_SETTING = {
  [COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_ATTRIBUTES]: 'Attributes',
  [COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_BUFFERED]: 'Buffered',
  [COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_CATALOG_NUMBER]: 'Catalog number',
  [COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_CITATIONS]: 'Citations',
  [COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_DEPICTIONS]: 'Depictions',
  [COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_PREPARATION]: 'Preparation',
  [COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_REPOSITORY]: 'Repository',
  [COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_VALIDATIONS]: 'Soft validations'
}

const store = useStore()
const preferences = computed(() => store.getters[GetterNames.GetPreferences].layout)
const showModal = ref(false)

</script>
