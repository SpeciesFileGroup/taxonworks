<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>
    <fieldset>
      <legend>Serial</legend>
      <SmartSelector
        model="serials"
        :klass="SOURCE"
        :target="SOURCE"
        label="name"
        @selected="(item) => (serial = item)"
      />
      <SmartSelectorItem
        :item="serial"
        label="name"
        @unset="serial = undefined"
      />
    </fieldset>

    <VBtn
      class="margin-large-top"
      color="create"
      medium
      :disabled="!serial || isCountExceeded"
      @click="move"
    >
      Update
    </VBtn>

    <div class="margin-large-top">
      <template v-if="sources.updated.length">
        <h3>Updated</h3>
        <ul>
          <li
            v-for="item in sources.updated"
            :key="item.id"
          >
            <a
              :href="`${RouteNames.NewSource}?source_id=${item.id}`"
              v-html="item.object_tag"
            />
          </li>
        </ul>
      </template>
      <template v-if="sources.not_updated.length">
        <h3>Not updated</h3>
        <ul>
          <li
            v-for="item in sources.not_updated"
            :key="item.id"
          >
            <a
              :href="`${RouteNames.NewSource}?source_id=${item.id}`"
              v-html="item.object_tag"
            />
          </li>
        </ul>
      </template>
    </div>
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { RouteNames } from '@/routes/routes.js'
import { Source } from '@/routes/endpoints'
import { SOURCE } from '@/constants/index.js'
import { computed, ref } from 'vue'

const MAX_LIMIT = 50

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  },

  count: {
    type: Number,
    required: true
  }
})

const serial = ref()
const sources = ref({ updated: [], not_updated: [] })

const isCountExceeded = computed(() => props.count > MAX_LIMIT)

function move() {
  const payload = {
    source_query: props.parameters,
    serial_id: serial.value.id
  }

  Source.batchUpdate(payload).then(({ body }) => {
    sources.value = body
    TW.workbench.alert.create(
      `${body.updated.length} sources were successfully updated.`,
      'notice'
    )
  })
}
</script>