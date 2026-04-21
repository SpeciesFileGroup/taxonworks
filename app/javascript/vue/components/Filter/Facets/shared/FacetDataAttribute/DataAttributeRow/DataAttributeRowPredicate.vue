<template>
  <div class="full_width">
    <div
      v-if="predicate"
      class="middle flex-separate gap-small"
    >
      <span v-html="predicate.name" />
      <VBtn
        color="primary"
        circle
        @click="() => (predicate = null)"
      >
        <VIcon
          name="close"
          xx-small
        />
      </VBtn>
    </div>
    <VBtn
      v-else
      color="primary"
      medium
      @click="() => (isModalVisible = true)"
    >
      Select predicate
    </VBtn>
    <VModal
      v-if="isModalVisible"
      :container-style="{ width: '600px' }"
      @close="() => (isModalVisible = false)"
    >
      <template #header>
        <h3>Select predicate</h3>
      </template>
      <template #body>
        <SmartSelector
          ref="smartSelectorRef"
          autocomplete-url="/controlled_vocabulary_terms/autocomplete"
          :autocomplete-params="{ 'type[]': 'Predicate' }"
          get-url="/controlled_vocabulary_terms/"
          model="predicates"
          buttons
          inline
          klass="DataAttribute"
          :add-tabs="['all']"
          @selected="(p) => (predicate = p)"
        >
          <template #all>
            <VModal @close="() => (isModalVisible = false)">
              <template #header>
                <h3>Predicates - all</h3>
              </template>
              <template #body>
                <div class="flex-wrap-row gap-small">
                  <VBtn
                    v-for="item in predicates"
                    :key="item.id"
                    color="primary"
                    pill
                    @click="
                      () => {
                        predicate = item
                        isModalVisible = false
                      }
                    "
                  >
                    {{ item.name }}
                  </VBtn>
                </div>
              </template>
            </VModal>
          </template>
        </SmartSelector>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'

const props = defineProps({
  predicates: {
    type: Array,
    required: true
  }
})

const predicate = defineModel({
  type: Object,
  default: null
})

const isModalVisible = ref(false)
</script>
