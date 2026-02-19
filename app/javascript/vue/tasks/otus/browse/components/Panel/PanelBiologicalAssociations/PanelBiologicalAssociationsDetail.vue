<template>
  <div class="ba-detail">
    <div class="ba-detail__header">
      <VBtn
        color="primary"
        medium
        @click="emit('close')"
      >
        <VIcon
          name="arrowLeft"
          x-small
        />
        Back
      </VBtn>
      <h3 class="ba-detail__title">Biological Association</h3>
      <div class="flex-row gap-small">
        <RadialAnnotator :global-id="association.globalId" />
        <RadialNavigator :global-id="association.globalId" />
      </div>
    </div>

    <div class="ba-detail__body">
      <div class="ba-detail__parties">
        <!-- Subject -->
        <div class="ba-detail__party">
          <h4 class="ba-detail__party-heading">Subject</h4>
          <dl class="ba-detail__dl">
            <template v-if="association.subjectOrder">
              <dt>Order</dt>
              <dd v-html="association.subjectOrder" />
            </template>
            <template v-if="association.subjectFamily">
              <dt>Family</dt>
              <dd v-html="association.subjectFamily" />
            </template>
            <template v-if="association.subjectGenus">
              <dt>Genus</dt>
              <dd v-html="association.subjectGenus" />
            </template>
            <dt>Label</dt>
            <dd>
              <a
                :href="
                  makeBrowseUrl({
                    id: association.subjectId,
                    type: association.subjectType
                  })
                "
                v-html="association.subjectTag"
              />
            </dd>
            <template v-if="association.biologicalPropertySubject">
              <dt>Biological property</dt>
              <dd v-html="association.biologicalPropertySubject" />
            </template>
          </dl>
        </div>

        <!-- Relationship -->
        <div class="ba-detail__relationship">
          <span
            class="ba-detail__relationship-label"
            v-html="association.biologicalRelationship"
          />
        </div>

        <!-- Object -->
        <div class="ba-detail__party">
          <h4 class="ba-detail__party-heading">Object</h4>
          <dl class="ba-detail__dl">
            <template v-if="association.objectOrder">
              <dt>Order</dt>
              <dd v-html="association.objectOrder" />
            </template>
            <template v-if="association.objectFamily">
              <dt>Family</dt>
              <dd v-html="association.objectFamily" />
            </template>
            <template v-if="association.objectGenus">
              <dt>Genus</dt>
              <dd v-html="association.objectGenus" />
            </template>
            <dt>Label</dt>
            <dd>
              <a
                :href="
                  makeBrowseUrl({
                    id: association.objectId,
                    type: association.objectType
                  })
                "
                v-html="association.objectTag"
              />
            </dd>
            <template v-if="association.biologicalPropertyObject">
              <dt>Biological property</dt>
              <dd v-html="association.biologicalPropertyObject" />
            </template>
          </dl>
        </div>
      </div>

      <!-- Citations -->
      <div
        v-if="association.citations.length"
        class="ba-detail__section"
      >
        <h4 class="ba-detail__section-heading">Citations</h4>
        <ul class="ba-detail__list">
          <li
            v-for="citation in association.citations"
            :key="citation.id"
          >
            <a
              :href="`/tasks/nomenclature/by_source?source_id=${citation.source_id}`"
              :title="citation.source.cached"
              v-html="citation.source.object_tag"
            />
            <span
              v-if="citation.pages"
              class="ba-detail__pages"
              >: {{ citation.pages }}</span
            >
          </li>
        </ul>
      </div>

      <!-- Tags -->
      <div
        v-if="association.tags.length"
        class="ba-detail__section"
      >
        <h4 class="ba-detail__section-heading">Tags</h4>
        <ul class="ba-detail__list">
          <li
            v-for="tag in association.tags"
            :key="tag.id"
            v-html="tag.label"
          />
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { makeBrowseUrl } from '@/helpers'

defineProps({
  association: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close'])
</script>

<style scoped>
.ba-detail {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: 12px;
}

.ba-detail__header {
  display: flex;
  align-items: center;
  gap: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid #ddd;
  margin-bottom: 16px;
  flex-shrink: 0;
}

.ba-detail__title {
  flex: 1;
  margin: 0;
}

.ba-detail__body {
  overflow-y: auto;
  flex: 1;
}

.ba-detail__parties {
  display: flex;
  align-items: flex-start;
  gap: 16px;
  margin-bottom: 20px;
}

.ba-detail__party {
  flex: 1;
  background: #f9f9f9;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  padding: 12px;
}

.ba-detail__party-heading {
  margin: 0 0 8px 0;
  font-size: 0.85em;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #555;
}

.ba-detail__relationship {
  display: flex;
  align-items: center;
  padding: 0 8px;
  flex-shrink: 0;
}

.ba-detail__relationship-label {
  font-weight: bold;
  text-align: center;
  white-space: nowrap;
}

.ba-detail__dl {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 4px 12px;
  margin: 0;
}

.ba-detail__dl dt {
  font-weight: 600;
  color: #444;
  white-space: nowrap;
}

.ba-detail__dl dd {
  margin: 0;
}

.ba-detail__section {
  margin-bottom: 16px;
}

.ba-detail__section-heading {
  margin: 0 0 6px 0;
  font-size: 0.85em;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #555;
}

.ba-detail__list {
  margin: 0;
  padding-left: 18px;
}

.ba-detail__pages {
  color: #666;
}
</style>
