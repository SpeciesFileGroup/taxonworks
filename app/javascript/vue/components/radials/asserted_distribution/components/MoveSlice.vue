<template>
  <div>
    <fieldset>
      <legend>Geographic area</legend>
      <SmartSelector
        model="geographic_areas"
        :klass="ASSERTED_DISTRIBUTION"
        :target="ASSERTED_DISTRIBUTION"
        label="name"
        @selected="(item) => (geographicArea = item)"
      />
      <SmartSelectorItem
        :item="geographicArea"
        label="name"
        @unset="geographicArea = undefined"
      />
    </fieldset>

    <VBtn
      class="margin-large-top"
      color="create"
      medium
      :disabled="!geographicArea"
      @click="move"
    >
      Move
    </VBtn>

    <div class="margin-large-top">
      <template v-if="moveResponse.updated.length">
        <h3>Updated</h3>
        <ul>
          <li
            v-for="item in moveResponse.updated"
            :key="item.id"
            v-html="item.object_tag"
          />
        </ul>
      </template>
      <template v-if="moveResponse.not_updated.length">
        <h3>Not updated</h3>
        <ul>
          <li
            v-for="item in moveResponse.not_updated"
            :key="item.id"
            v-html="item.object_tag"
          />
        </ul>
      </template>
    </div>
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { AssertedDistribution } from '@/routes/endpoints'
import { ASSERTED_DISTRIBUTION } from '@/constants/index.js'
import { ref } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const geographicArea = ref()
const moveResponse = ref({
  updated: [],
  not_updated: []
})

function move() {
  const payload = {
    asserted_distribution_query: props.parameters,
    geographic_area_id: geographicArea.value.id
  }

  AssertedDistribution.batchUpdate(payload)
    .then(({ body }) => {
      moveResponse.value = body
      TW.workbench.alert.create(
        `${body.updated.length} asserted distribution items were successfully updated.`,
        'notice'
      )
    })
    .catch(() => {})
}
</script>
