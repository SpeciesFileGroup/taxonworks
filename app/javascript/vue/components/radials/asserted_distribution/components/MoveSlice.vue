<template>
  <div>
    <fieldset>
      <legend>Geographic area</legend>
      <SmartSelector
        model="geographic_areas"
        :klass="ASSERTED_DISTRIBUTION"
        :target="ASSERTED_DISTRIBUTION"
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
      <template v-if="moveResponse.moved.length">
        <h3>Moved</h3>
        <ul>
          <li
            v-for="item in moveResponse.moved"
            :key="item.id"
            v-html="item.object_tag"
          />
        </ul>
      </template>
      <template v-if="moveResponse.unmoved.length">
        <h3>Unmoved</h3>
        <ul>
          <li
            v-for="item in moveResponse.unmoved"
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
  moved: [],
  unmoved: []
})

function move() {
  const payload = {
    asserted_distribution_query: props.parameters,
    geographic_area_id: geographicArea.value.id
  }

  AssertedDistribution.moveBatch(payload).then(({ body }) => {
    moveResponse.value = body
    TW.workbench.alert.create(
      `${body.moved.length} asserted distribution items were successfully updated.`,
      'notice'
    )
  })
}
</script>
