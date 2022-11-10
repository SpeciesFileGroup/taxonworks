<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="isVisible = true"
      :disabled="!navigate.current_collection_object"
    >
      Go
    </button>
    <modal-component
      v-if="isVisible"
      @close="isVisible = false"
      :container-style="{ width: '500px'}"
    >
      <template #header>
        <h3>Navigate</h3>
      </template>
      <template #body>
        <p>Current: <span v-html="collectionObject.object_tag" /></p>
        <table class="full_width">
          <thead>
            <tr>
              <th>Previous by</th>
              <th>Next by</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="key in Object.keys(navigate.previous_by || navigate.next_by)"
              :key="key"
            >
              <td>
                <button
                  type="button"
                  class="button normal-input button-default"
                  :disabled="!navigate.previous_by[key]"
                  @click="loadCO(navigate.previous_by[key])"
                >
                  {{ key.replaceAll('_', ' ') }}
                </button>
              </td>
              <td>
                <button
                  class="button normal-input button-default"
                  type="button"
                  :disabled="!navigate.next_by[key]"
                  @click="loadCO(navigate.next_by[key])"
                >
                  {{ key.replaceAll('_', ' ') }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </template>
    </modal-component>
  </div>
</template>

<script setup>

import { useStore } from 'vuex'
import { computed, ref } from 'vue'
import { GetterNames } from '../store/getters/getters'
import ModalComponent from 'components/ui/Modal'
import loadCO from '../utils/loadCO.js'

const store = useStore()
const navigate = computed(() => store.getters[GetterNames.GetNavigation])
const collectionObject = computed(() => store.getters[GetterNames.GetCollectionObject])

const isVisible = ref(false)


</script>
