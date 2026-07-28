<template>
  <div class="flex-row gap-small middle">
    <VBtn
      v-help.nav.previous
      icon
      color="primary"
      variant="tonal"
      title="Load previous collection object by ID"
      :disabled="!previousByCurrent"
      @click="loadCO(previousByCurrent)"
    >
      <IconArrowLeft class="w-4 h-4" />
    </VBtn>
    <VBtn
      v-help.nav.go
      color="primary"
      variant="tonal"
      @click="isVisible = true"
      :disabled="!navigate.current_collection_object"
    >
      Navigate
    </VBtn>
    <VBtn
      v-help.nav.next
      icon
      color="primary"
      variant="tonal"
      title="Load next collection object by ID"
      :disabled="!nextByCurrent"
      @click="loadCO(nextByCurrent)"
    >
      <IconArrowRight class="w-4 h-4" />
    </VBtn>
    <VModal
      v-if="isVisible"
      @close="isVisible = false"
      :container-style="{ width: '500px' }"
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
              v-for="key in Object.keys(
                navigate.previous_by || navigate.next_by
              )"
              :key="key"
            >
              <td>
                <VBtn
                  color="primary"
                  variant="tonal"
                  :disabled="!navigate.previous_by[key]"
                  @click="loadCO(navigate.previous_by[key])"
                >
                  {{ key.replaceAll('_', ' ') }}
                </VBtn>
              </td>
              <td>
                <VBtn
                  color="primary"
                  variant="tonal"
                  :disabled="!navigate.next_by[key]"
                  @click="loadCO(navigate.next_by[key])"
                >
                  {{ key.replaceAll('_', ' ') }}
                </VBtn>
              </td>
            </tr>
          </tbody>
        </table>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed, ref } from 'vue'
import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import { RouteNames } from '@/routes/routes'
import VModal from '@/components/ui/Modal'
import setParam from '@/helpers/setParam'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconArrowLeft from '@/components/Icon/IconArrowLeft.vue'
import IconArrowRight from '@/components/Icon/IconArrowRight.vue'

const store = useStore()

const isVisible = ref(false)
const currentNavigation = ref('id')

const navigate = computed(() => store.getters[GetterNames.GetNavigation])
const collectionObject = computed(
  () => store.getters[GetterNames.GetCollectionObject]
)

const previousByCurrent = computed(
  () =>
    navigate.value?.previous_by &&
    navigate.value.previous_by[currentNavigation.value]
)
const nextByCurrent = computed(
  () =>
    navigate.value?.next_by && navigate.value.next_by[currentNavigation.value]
)

function loadCO(coId) {
  store.dispatch(ActionNames.ResetStore)
  store.dispatch(ActionNames.LoadCollectionObject, coId)
  setParam(RouteNames.BrowseCollectionObject, 'collection_object_id', coId)
}
</script>
