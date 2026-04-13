<template>
  <div>
    <WktComponent
      class="margin-medium-bottom"
      @create="(wkt) => emit('newShape', wkt, GZ_WKT)"
    />
    <PointComponent
      :title="'Add a point by lat, long'"
      :include-range="false"
      @create="(e) => emit('newShape', e, GZ_POINT)"
    />
  </div>
</template>

<script setup>
import PointComponent from '@/components/georeferences/manuallyComponent.vue'
import WktComponent from '@/components/Form/FormCollectingEvent/components/parsed/georeferences/wkt.vue'
import { GZ_POINT, GZ_WKT } from '@/constants/index.js'

const emit = defineEmits(['newShape'])
</script>
