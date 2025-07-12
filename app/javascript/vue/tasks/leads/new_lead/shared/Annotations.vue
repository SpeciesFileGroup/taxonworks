<template>
  <template v-if="depictions.length">
    <h3>Depictions</h3>
    <div class="depictions_holder">
      <ImageViewer
        v-for="depiction in depictions"
        :key="depiction.id"
        :depiction="depiction"
        edit
      />
    </div>
  </template>

  <template v-if="citations && citations.length">
    <h3>Citations</h3>
    <div
      v-for="citation in citations"
      :key="citation.id"
    >
      <div class="lead_citation">
        <a :href="citation.source.object_url" target="_blank">
          <span v-html="citation.source.object_tag" />
        </a>
      </div>
    </div>
  </template>
</template>

<script setup>
import { Citation, Depiction } from '@/routes/endpoints'
import { watch } from 'vue'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer'

const props = defineProps({
  object_type: {
    type: String,
    required: true
  },

  object_id: {
    type: Number,
    required: true
  }
})

const depictions = defineModel(
  'depiction',
  {
    type: Array,
    required: true
  }
)

const citations = defineModel(
  'citation',
  {
    type: Array,
    required: false
  }
)

function updateDepictions() {
  Depiction
    .where({
      depiction_object_id: [props.object_id],
      depiction_object_type: props.object_type
    })
    .then(({ body }) => {
      depictions.value = body.sort((a, b) => a.position - b.position)
    })
}

function updateCitations() {
  Citation
    .where({
      citation_object_id: [props.object_id],
      citation_object_type: props.object_type,
      extend: ['source']
    })
    .then(({ body }) => {
      citations.value = body.sort((a, b) => a.id - b.id)
    })
}

watch(
  () => props.object_id,
  () => {
    updateDepictions()
    if (citations.value) {
      updateCitations()
    }
  },
  { immediate: true }
)
</script>

<style lang="scss" scoped>
.depictions_holder {
  display: flex;
  flex-wrap: wrap;
}
.lead_citation {
  margin-bottom: 16px;
}
</style>