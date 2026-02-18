<template>
  <div>
    <tippy
      v-if="store.coordinateOtus.length > 1"
      animation="scale"
      placement="bottom"
      size="small"
      inertia
      arrow
    >
      <VBtn
        color="primary"
        @click="() => (isModalVisible = true)"
      >
        Coordinate OTUs ({{ store.coordinateOtus.length }})

        <VIcon
          name="attention"
          color="attention"
          x-small
        />
      </VBtn>
      <template #content>
        <div class="padding-small text-xs">
          <ul class="no_bullets">
            <li
              v-for="otu in store.coordinateOtus"
              :key="otu.id"
              class="horizontal-left-content gap-small"
            >
              <span
                :class="{
                  'font-bold': store.selectedOtus.some((o) => o.id === otu.id)
                }"
                v-html="otu.object_label"
              />
            </li>
          </ul>
        </div>
      </template>
    </tippy>
    <VModal
      v-if="isModalVisible"
      :container-style="{ width: '700px' }"
      @close="() => (isModalVisible = false)"
    >
      <template #header>
        <h3>Coordinate OTUs</h3>
      </template>
      <template #body>
        <p>
          Select the OTUs to filter the data. Each panel will display
          information according to the selected OTUs.
        </p>
        <table class="full_width table-striped">
          <thead>
            <tr>
              <th>
                <ButtonUnify
                  :ids="otus.map((o) => o.id)"
                  :model="OTU"
                />
              </th>
              <th></th>
              <th>OTU</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="otu in store.coordinateOtus"
              :key="otu.id"
            >
              <td class="w-2">
                <input
                  type="checkbox"
                  :value="otu"
                  v-model="otus"
                />
              </td>
              <td class="w-2">
                <div class="horizontal-left-content gap-small">
                  <RadialAnnotator :global-id="otu.global_id" />
                  <RadialObject :global-id="otu.global_id" />
                  <RadialNavigator :global-id="otu.global_id" />
                </div>
              </td>
              <td v-html="otu.object_tag" />
            </tr>
          </tbody>
        </table>
      </template>
      <template #footer>
        <VBtn
          color="primary"
          @click="
            () => {
              store.selectedOtus = [...otus]
              isModalVisible = false
            }
          "
        >
          Apply
        </VBtn>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { watch, ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import ButtonUnify from '@/components/ui/Button/ButtonUnify.vue'
import { Tippy } from 'vue-tippy'
import { useOtuStore } from '../store'
import { OTU } from '@/constants'

const otus = ref([])
const isModalVisible = ref(false)
const store = useOtuStore()

watch(isModalVisible, () => {
  otus.value = [...store.selectedOtus]
})
</script>
