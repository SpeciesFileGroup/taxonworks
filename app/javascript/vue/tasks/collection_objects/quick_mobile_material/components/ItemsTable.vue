<template>
  <table class="full_width table-striped">
    <thead>
      <tr>
        <th>Namespace</th>
        <th>Catalog number</th>
        <th>Buffered collecting event</th>
        <th>Images</th>
        <th class="w-2" />
      </tr>
    </thead>
    <tbody>
      <tr v-if="!items.length">
        <td colspan="5">Nothing synchronized yet.</td>
      </tr>
      <tr
        v-for="item in items"
        :key="item.id"
      >
        <td>{{ item.catalog_number?.namespace_name }}</td>
        <td>{{ item.catalog_number?.identifier }}</td>
        <td>
          {{ item.buffered_collecting_event }}
          <span
            v-if="item.ignored.length"
            class="feedback feedback-thin feedback-warning"
            :title="`Sent from the mobile app but not applied: ${item.ignored.join(', ')}`"
          >
            Not applied: {{ item.ignored.join(', ') }}
          </span>
        </td>
        <td>
          <div class="horizontal-left-content gap-xsmall flex-wrap-row">
            <a
              v-for="depiction in item.depictions"
              :key="depiction.id"
              :href="depiction.medium_url"
              target="_blank"
            >
              <img
                :src="depiction.thumb_url"
                alt="Thumbnail"
              />
            </a>
          </div>
        </td>
        <td>
          <div class="horizontal-right-content gap-small">
            <RadialAnnotator :global-id="item.global_id" />
            <RadialNavigator :global-id="item.global_id" />
            <RadialObject :global-id="item.global_id" />
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
// Kept free of fetching, so a later Cable subscription can update `items`.
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import RadialObject from '@/components/radials/object/radial.vue'

defineProps({
  items: {
    type: Array,
    default: () => []
  }
})
</script>
