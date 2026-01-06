<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default margin-small-bottom"
      @click="() => (isModalVisible = true)"
    >
      Select
    </button>
    <VModal
      v-if="isModalVisible"
      @close="() => (isModalVisible = false)"
      :container-style="{
        width: '500px',
        overflow: 'scroll',
        maxHeight: '80vh'
      }"
    >
      <template #header>
        <h3>OTUs</h3>
      </template>
      <template #body>
        <div class="horizontal-left-content gap-small margin-medium-bottom">
          <button
            v-if="isAllSelected"
            type="button"
            class="button normal-input button-default"
            @click="() => (selectedIds = [])"
          >
            Unselect all
          </button>
          <button
            v-else
            type="button"
            class="button normal-input button-default"
            @click="() => (selectedIds = [...otuIds])"
          >
            Select all
          </button>
          <ButtonImageMatrix :otu-ids="otuIds" />
          <RadialMatrix
            :ids="otuIds"
            :disabled="!otuIds.length"
            :object-type="OTU"
          />
        </div>
        <ul class="no_bullets">
          <li
            v-for="item in list"
            :key="item.id"
            class="margin-small-bottom middle"
          >
            <label>
              <input
                v-model="selectedIds"
                :value="item.id"
                type="checkbox"
              />
              <span v-html="item.object_tag" />
            </label>
          </li>
        </ul>
      </template>
      <template #footer>
        <div class="horizontal-left-content gap-small">
          <button
            v-if="isAllSelected"
            type="button"
            class="button normal-input button-default"
            @click="() => (selectedIds = [])"
          >
            Unselect all
          </button>
          <button
            v-else
            type="button"
            class="button normal-input button-default"
            @click="() => (selectedIds = [...otuIds])"
          >
            Select all
          </button>
          <ButtonImageMatrix :otu-ids="otuIds" />
          <RadialMatrix
            :ids="otuIds"
            :disabled="!otuIds.length"
            :object-type="OTU"
          />
        </div>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import VModal from '@/components/ui/Modal'
import ButtonImageMatrix from '@/tasks/observation_matrices/dashboard/components/buttonImageMatrix.vue'
import RadialMatrix from '@/components/radials/matrix/radial.vue'
import { OTU } from '@/constants/index.js'
import { computed, ref } from 'vue'

const props = defineProps({
  list: {
    type: Array,
    required: true
  }
})

const isModalVisible = ref(false)
const selectedIds = ref([])

const otuIds = computed(() => props.list.map((o) => o.id))

const isAllSelected = computed({
  get: () => otuIds.value.length === selectedIds.value.length
})
</script>
