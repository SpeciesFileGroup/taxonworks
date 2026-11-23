<template>
  <div>
    <VTooltip
      v-if="store.coordinateOtus.length > 1"
      placement="bottom"
    >
      <VBtn
        color="primary"
        @click="() => (isModalVisible = true)"
      >
        Coordinate OTUs ({{ store.coordinateOtus.length }})
      </VBtn>
      <template #content>
        <ul class="no_bullets">
          <li
            v-for="otu in previewCoordinateOtus"
            :key="otu.id"
            class="horizontal-left-content gap-small"
          >
            <span
              v-if="store.selectedOtus.some((o) => o.id === otu.id)"
              class="font-bold"
            >
              > {{ otu.object_label }}
            </span>
            <span
              v-else
              v-html="otu.object_label"
            />
          </li>
          <li v-if="hiddenCoordinateOtusCount">
            ... and {{ hiddenCoordinateOtusCount }} more
          </li>
        </ul>
      </template>
    </VTooltip>
    <VModal
      v-if="isModalVisible"
      :container-style="{ width: '700px' }"
      @close="() => (isModalVisible = false)"
    >
      <template #header>
        <h3>Coordinate OTUs</h3>
      </template>
      <template #body>
        <div class="horizontal-left-content gap-medium margin-medium-bottom">
          <label
            v-for="(label, scope) in OTU_SCOPES"
            :key="scope"
          >
            <input
              v-model="store.otuScope"
              type="radio"
              :value="scope"
            />
            {{ label }}
          </label>
        </div>
        <input
          v-model="searchText"
          type="text"
          class="full_width margin-medium-bottom"
          placeholder="Filter OTUs..."
        />
        <table class="full_width table-striped">
          <thead>
            <tr>
              <th />
              <th>
                <ButtonUnify
                  :ids="otusToUnify.map((o) => o.id)"
                  :model="OTU"
                />
              </th>
              <th>OTU</th>
              <th />
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="otu in filteredCoordinateOtus"
              :key="otu.id"
            >
              <td class="w-2">
                <input
                  type="checkbox"
                  title="Select to unify"
                  :value="otu"
                  v-model="otusToUnify"
                />
              </td>
              <td class="w-2">
                <div class="horizontal-left-content gap-small">
                  <RadialAnnotator :global-id="otu.global_id" />
                  <RadialObject :global-id="otu.global_id" />
                  <RadialNavigator :global-id="otu.global_id" />
                </div>
              </td>
              <td>
                <span
                  v-if="store.otu?.id === otu.id"
                  v-html="otu.object_tag"
                />
                <a
                  v-else
                  :href="`${RouteNames.BrowseOtu}?otu_id=${otu.id}`"
                  data-turbolinks="false"
                  v-html="otu.object_tag"
                />
              </td>
              <td class="w-2">
                <span
                  v-if="store.otu?.id === otu.id"
                  class="subtle"
                >
                  Current
                </span>
                <VBtn
                  v-else
                  circle
                  color="primary"
                  title="Set as current OTU: header and single-OTU panels will display this OTU"
                  @click="() => store.setCurrentOtu(otu.id)"
                >
                  <VIcon
                    name="focus"
                    x-small
                  />
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
import { computed, watch, ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VModal from '@/components/ui/Modal.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import ButtonUnify from '@/components/ui/Button/ButtonUnify.vue'
import VTooltip from '@/components/ui/VTooltip/VTooltip.vue'
import { useOtuStore } from '../store'
import { OTU_SCOPES } from '../constants/otuScope.js'
import { OTU } from '@/constants'
import { RouteNames } from '@/routes/routes'

const MAX_TOOLTIP_OTUS = 10

const otusToUnify = ref([])
const isModalVisible = ref(false)
const searchText = ref('')
const store = useOtuStore()

const previewCoordinateOtus = computed(() =>
  store.coordinateOtus.slice(0, MAX_TOOLTIP_OTUS)
)

const hiddenCoordinateOtusCount = computed(() =>
  Math.max(store.coordinateOtus.length - MAX_TOOLTIP_OTUS, 0)
)

const filteredCoordinateOtus = computed(() => {
  const term = searchText.value.trim().toLowerCase()

  if (!term) return store.coordinateOtus

  return store.coordinateOtus.filter((otu) =>
    (otu.object_label || '').toLowerCase().includes(term)
  )
})

watch(isModalVisible, () => {
  otusToUnify.value = []
  searchText.value = ''
})
</script>
