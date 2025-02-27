<template>
  <div>
    <div class="margin-medium-bottom font-bold">Topics</div>

    <div
      v-if="store.selected.citation"
      class="flex-wrap-row gap-medium"
    >
      <ul
        class="flex-wrap-column no_bullets gap-xsmall"
        v-for="itemsGroup in chunkArray(
          store.topics,
          Math.ceil(store.topics.length / 4)
        )"
        :key="itemsGroup"
      >
        <li
          class="topics"
          v-for="item in itemsGroup"
          :key="item.id"
        >
          <CitationTopicCheckbox :topic="item" />
        </li>
      </ul>
    </div>
  </div>
</template>
<script setup>
import { chunkArray } from '@/helpers/arrays.js'
import useStore from '../../../store/store.js'
import CitationTopicCheckbox from './CitationTopicCheckbox.vue'

const store = useStore()
</script>
