<template>
  <div
    class="horizontal-left-content margin-medium-top margin-medium-bottom"
  >
    <WktComponent
      :disabled="inputsDisabled"
      :type="GZ_WKT"
      id-key="uuid"
      :id-generator="() => randomUUID()"
      @create="(wkt) => emit('newShape', wkt, GZ_WKT)"
      class="margin-small-right"
    >
      <template #header>
        <h3>Create WKT shape</h3>
      </template>
    </WktComponent>

    <PointComponent
      :disabled="inputsDisabled"
      class="margin-small-right"
      :title="'Add a point by lat, long'"
      :include-range="false"
      @create="(e) => emit('newShape', e, GZ_POINT)"
    />
<!--
    <geolocate-component
      :disabled="!collectingEvent.id"
      class="margin-small-right"
      @create="addToQueue"
    />
-->
  </div>
</template>

<script setup>
import PointComponent from '@/components/georeferences/manuallyComponent.vue'
import WktComponent from '@/tasks/collecting_events/new_collecting_event/components/parsed/georeferences/wkt.vue'
import { randomUUID } from '@/helpers'
import {
  GZ_POINT,
  GZ_WKT,
} from '@/constants/index.js'

const props = defineProps({
  inputsDisabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['newShape'])
</script>