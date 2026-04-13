<template>
  <div>
    <div v-if="depictions.length">
      <h3 v-if="!mediumDepictions">Depictions</h3>
      <div class="depictions_holder">
        <ImageViewer
          v-for="depiction in depictions"
          :key="depiction.id"
          :depiction="depiction"
          :thumb-size="mediumDepictions ? 'medium' : 'thumb'"
        >
          <template #thumbfooter
            v-if="mediumDepictions"
          >
            <div :style="'width: ' + captionWidth(depiction) + 'px' ">
              <ul class="no_bullets figure_text">
                <li v-if="depiction.figure_label">
                  <u>
                    {{ depiction.figure_label }}
                  </u>
                </li>
                <li v-if="depiction.caption">
                  {{ depiction.caption }}
                </li>
              </ul>
            </div>
          </template>
        </ImageViewer>
      </div>
    </div>

    <div v-if="showCitations && citations.length">
      <h3>Citations</h3>
      <div
        v-for="citation in citations"
        :key="citation.id"
      >
        <div class="lead_citation">
          <a :href="citation.source.object_url" target="_blank">
            {{ citation.citation_source_body }}
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { Citation, Depiction } from '@/routes/endpoints'
import { LEAD } from '@/constants/index.js'
import { ref, watch } from 'vue'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer'

const props = defineProps({
  leadId: {
    type: Number,
    required: true
  },
  showCitations: {
    type: Boolean,
    default: true
  },
  mediumDepictions: {
    type: Boolean,
    default: false
  }
})

const hasDepictions = defineModel(
  {
    type: Boolean,
    default: false
  }
)

const depictions = ref([])

function loadDepictions() {
  Depiction
    .where({
      depiction_object_id: [props.leadId],
      depiction_object_type: LEAD
    })
    .then(({ body }) => {
      depictions.value = body.sort((a, b) => a.position - b.position)
      hasDepictions.value = depictions.value.length > 0
    })
}

const citations = ref([])

function loadCitations() {
  Citation
    .where({
      citation_object_id: [props.leadId],
      citation_object_type: LEAD,
      extend: ['source']
    })
    .then(({ body }) => {
      citations.value = body.sort((a, b) => a.id - b.id)
    })
}

watch(
  () => props.leadId,
  () => {
    loadDepictions()
    if (props.showCitations) {
      loadCitations()
    }
  },
  { immediate: true }
)

function captionWidth(depiction) {
  return Math.max(depiction.image.alternatives['medium'].width, 100)
}
</script>

<style lang="scss" scoped>
.depictions_holder {
  display: flex;
  flex-wrap: wrap;
}
.lead_citation {
  margin-bottom: 1em;
}
.figure_text {
  li {
    overflow-wrap: break-word;
  }
}
</style>
