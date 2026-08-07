<template>
  <div class="position-relative">
    <div class="hexagon-validation">
      <div
        class="cursor-pointer middle"
        v-html="badge"
        @click="() => (isModalVisible = true)"
      />
      <div class="panel content hexagon-information">
        <ul class="no_bullets">
          <li
            class="horizontal-left-content"
            v-for="(segment, key) in SEGMENTS"
            :key="key"
          >
            <div
              class="hexagon-info-square margin-small-right"
              :style="{ 'background-color': key }"
            />
            {{ segment }}
          </li>
        </ul>
      </div>
    </div>
    <VModal
      v-if="isModalVisible"
      :container-style="{ width: '500px' }"
      @close="() => (isModalVisible = false)"
    >
      <template #header>
        <h3 />
      </template>
      <template #body>
        <SoftValidationPanel :validations="softValidations" />
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { CollectionObject } from '@/routes/endpoints'
import { GetterNames } from '../../store/getters/getters'
import { useStore } from 'vuex'
import VModal from '@/components/ui/Modal'
import SoftValidationPanel from '@/components/soft_validations/panel.vue'
import useSoftValidationStore from '@/components/Form/FormCollectingEvent/store/softValidations'

const SEGMENTS = {
  yellow: 'Identifiers',
  orange: 'Taxon determinations',
  red: 'Georeferences',
  purple: 'Collecting events',
  blue: 'Buffered determinations',
  green: 'Buffered collecting event'
}

const softValidationStore = useSoftValidationStore()
const store = useStore()

const collectionObject = computed(
  () => store.getters[GetterNames.GetCollectionObject]
)

const lastSave = computed(() => store.getters[GetterNames.GetSettings].lastSave)

const softValidations = computed(() => ({
  ...store.getters[GetterNames.GetSoftValidations],
  ...softValidationStore.softValidations
}))

const isModalVisible = ref(false)
const badge = ref()

function getBadge(id) {
  CollectionObject.metadataBadge(id).then((response) => {
    badge.value = response.body.svg
  })
}

watch(lastSave, (newVal) => {
  if (newVal && collectionObject.value.id) {
    getBadge(collectionObject.value.id)
  }
})

getBadge(collectionObject.value.id)
</script>

<style scoped>
.hexagon-validation {
  position: relative;
}

.hexagon-validation:hover {
  .hexagon-information {
    display: block;
  }
}

.hexagon-information {
  display: none;
  position: absolute;
  padding: 1em;
  width: 170px;
}

.hexagon-info-square {
  width: 8px;
  height: 8px;
}
</style>
