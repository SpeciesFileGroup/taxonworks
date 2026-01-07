<template>
  <div class="content">
    <h3>Eliminated ({{ list.length }})</h3>
    <ul>
      <li
        v-for="item in list"
        :key="item.id"
      >
        <a
          :href="makeBrowseUrl({ id: item.id, type: OTU })"
          v-html="item.object_tag"
        />
      </li>
    </ul>
  </div>
</template>

<script setup>
import { OTU } from '@/constants'
import { makeBrowseUrl } from '@/helpers'

const props = defineProps({
  list: {
    type: Array,
    required: true
  }
})
</script>
