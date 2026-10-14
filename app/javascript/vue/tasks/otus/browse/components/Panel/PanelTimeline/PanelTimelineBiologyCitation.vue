<template>
  <span>
    <a
      v-html="item.otu.label"
      :href="`${RouteNames.BrowseOtu}?otu_id=${item.otu.id}`"
    />
    in
    <a
      :href="`${RouteNames.NomenclatureBySource}?source_id=${item.source.id}`"
      v-html="item.label"
    />
    <VBadge
      class="d-inline margin-xsmall-left margin-xsmall-right"
      color="purple"
      rounded
      >{{ item.type }}</VBadge
    >
    <span class="history__citation_topics">
      <div
        class="pill topic d-inline"
        :style="{
          backgroundColor: topic.css_color
        }"
        v-for="topic in item.citationTopics"
        :key="topic.id"
      >
        {{ topic.name }}
      </div>
    </span>
  </span>
</template>

<script setup>
import { RouteNames } from '@/routes/routes'
import VBadge from '@/components/ui/VBadge/VBadge.vue'

defineProps({
  item: {
    type: Object,
    required: true
  }
})
</script>
