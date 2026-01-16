<template>
  <div class="attribution-replace">
    <div class="margin-medium-bottom">
      <h4>
        Change (match criteria)
        <VBtn
          v-if="replaceAttribution"
          circle
          color="primary"
          @click="replaceAttribution = null"
        >
          <VIcon
            name="trash"
            x-small
          />
        </VBtn>
      </h4>
      <div
        v-if="replaceAttribution"
        class="attribution-summary"
      >
        <AttributionSummary :attribution="replaceAttribution" />
      </div>
      <AttributionForm
        v-else
        :klass="klass"
        button-label="Set as match"
        button-color="primary"
        @attribution="(attr) => (replaceAttribution = attr)"
      />
    </div>

    <div class="margin-medium-bottom">
      <h4>
        To (new values)
        <VBtn
          v-if="toAttribution"
          circle
          color="primary"
          @click="toAttribution = null"
        >
          <VIcon
            name="trash"
            x-small
          />
        </VBtn>
      </h4>
      <div
        v-if="toAttribution"
        class="attribution-summary"
      >
        <AttributionSummary :attribution="toAttribution" />
      </div>
      <AttributionForm
        v-else
        :klass="klass"
        button-label="Set as target"
        button-color="primary"
        @attribution="(attr) => (toAttribution = attr)"
      />
    </div>

    <VBtn
      color="update"
      :disabled="!isFilled"
      @click="() => emit('select', [replaceAttribution, toAttribution])"
    >
      Replace
    </VBtn>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import AttributionForm from './attributions.vue'
import AttributionSummary from './AttributionSummary.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

defineProps({
  klass: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['select'])

const replaceAttribution = ref(null)
const toAttribution = ref(null)

const isFilled = computed(
  () => replaceAttribution.value !== null && toAttribution.value !== null
)
</script>

<style scoped>
.attribution-summary {
  padding: 8px;
  background-color: var(--bg-muted);
  border-radius: 4px;
  margin-bottom: 8px;
}
</style>
