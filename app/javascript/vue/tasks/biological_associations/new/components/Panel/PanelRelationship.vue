<template>
  <BlockLayout :warning="!relationship">
    <template #header><h3>Relationship</h3></template>
    <template #body>
      <div class="horizontal-left-content align-start gap-small">
        <SmartSelector
          v-model="relationship"
          class="full_width"
          model="biological_relationships"
          target="Otu"
          klass="Otu"
          pin-section="BiologicalRelationships"
          buttons
          inline
          label="name"
          :custom-list="{
            all: list
          }"
          pin-type="BiologicalRelationship"
        >
          <template #tabs-right>
            <VLock v-model="lock" />
          </template>
        </SmartSelector>
      </div>
      <hr
        v-if="relationship"
        class="divisor"
      />
      <SmartSelectorItem
        :item="relationship"
        @unset="() => (relationship = null)"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { BiologicalRelationship } from '@/routes/endpoints'
import { ref } from 'vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VLock from '@/components/ui/VLock/index.vue'

const relationship = defineModel({
  type: Object,
  default: null
})

const lock = defineModel('lock', {
  type: Boolean,
  default: false
})

const list = ref([])

BiologicalRelationship.all().then(({ body }) => {
  list.value = body
})
</script>
