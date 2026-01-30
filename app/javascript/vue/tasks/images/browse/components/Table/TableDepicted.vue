<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th
          v-if="hasSvgClips"
          class="w-2"
        >
          <input
            type="checkbox"
            v-model="selectAllToggle"
          />
        </th>
        <th>Depicted objects</th>
        <th></th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in store.depictions"
        :key="item.id"
      >
        <td v-if="hasSvgClips">
          <input
            v-if="item.svg_clip"
            type="checkbox"
            :value="item"
            v-model="store.selected"
          />
        </td>
        <td v-html="item.depiction_object.object_tag" />
        <td>
          <div class="flex-row gap-small">
            <RadialAnnotator :global-id="item.depiction_object.global_id" />
            <RadialQuickForms :global-id="item.depiction_object.global_id" />
            <RadialNavigator :global-id="item.depiction_object.global_id" />
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import RadialQuickForms from '@/components/radials/object/radial.vue'
import useStore from '../../store/store.js'
import { computed } from 'vue'

const props = defineProps({
  records: {
    type: Array,
    required: true
  }
})

const hasSvgClips = computed(() => store.depictions.some((d) => d.svg_clip))

const selectAllToggle = computed({
  get: () =>
    store.depictions.length &&
    store.selected.length &&
    store.depictions.length === store.selected.length,
  set: (value) => {
    store.selected = value ? [...store.depictions] : []
  }
})

const store = useStore()
</script>
