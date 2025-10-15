<template>
 <div>
    <div class="horizontal-left-content gap-small">
      <h2>Edit anatomical part</h2>
      <template v-if="!!anatomicalPart">
        <RadialAnnotator :global-id="anatomicalPart.global_id" />
        <RadialObject :global-id="anatomicalPart.global_id" />
        <RadialNavigator :global-id="anatomicalPart.global_id" />
      </template>
    </div>

    <AnatomicalParts
      @anatomical-part-loaded="(part) => (anatomicalPart = part)"
    />
  </div>
</template>

<script setup>
import AnatomicalParts from '@/components/radials/object/components/origin_relationship/create/anatomical_parts/AnatomicalParts.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import { ref } from 'vue'

const anatomicalPart = ref(undefined)

</script>