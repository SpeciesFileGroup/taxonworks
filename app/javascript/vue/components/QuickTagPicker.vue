<template>
  <BlockLayout
    expand
    class="margin-medium-bottom"
  >
    <template #header>
      <h3>Tags</h3>
    </template>

    <template #body>
      <div
        v-if="!availableKeywords.length && !tags.length"
        class="small_type padding-xsmall"
      >
        No tags have been applied to any {{ objectType }} records in this
        project yet. Add one via the radial annotator.
      </div>

      <template v-else>
        <label class="font-bold">Attached</label>
        <div
          v-if="tags.length"
          class="d-flex flex-wrap-row gap-small margin-small-top margin-medium-bottom"
        >
          <span
            v-for="tag in attachedTags"
            :key="tag.id"
            class="pill keyword keyword-clickable"
            role="button"
            tabindex="0"
            :style="keywordPillStyle(tag.keyword)"
            :title="`${tag.keyword?.name}${tag.keyword?.definition ? ' — ' + tag.keyword.definition : ''} (click to remove)`"
            @click="!busy && removeTag(tag)"
            @keydown.enter.prevent="!busy && removeTag(tag)"
            @keydown.space.prevent="!busy && removeTag(tag)"
          >
            <span>{{ tag.keyword?.name }} <span
              aria-hidden="true"
              class="tag-remove"
            >×</span></span>
          </span>
        </div>
        <div
          v-else
          class="small_type padding-xsmall margin-medium-bottom"
        >
          None yet — click a tag below to attach it.
        </div>

        <label class="font-bold">Available tags</label>
        <div
          v-if="unattachedKeywords.length"
          class="d-flex flex-wrap-row gap-small margin-small-top"
        >
          <span
            v-for="keyword in unattachedKeywords"
            :key="keyword.id"
            class="pill keyword keyword-clickable keyword-outline"
            role="button"
            tabindex="0"
            :style="keywordOutlineStyle(keyword)"
            :title="`${keyword.name}${keyword.definition ? ' — ' + keyword.definition : ''} (click to attach)`"
            @click="!busy && attachKeyword(keyword)"
            @keydown.enter.prevent="!busy && attachKeyword(keyword)"
            @keydown.space.prevent="!busy && attachKeyword(keyword)"
          >
            <span>{{ keyword.name }}</span>
          </span>
        </div>
        <div
          v-else
          class="small_type padding-xsmall"
        >
          All existing tags are already attached.
        </div>
      </template>
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import { Tag } from '@/routes/endpoints'
import { computed, ref, watch } from 'vue'

const props = defineProps({
  objectType: {
    type: String,
    required: true
  },

  objectId: {
    type: Number,
    required: true
  }
})

const availableKeywords = ref([])
const tags = ref([])
const busy = ref(false)

const tagsByKeywordId = computed(() =>
  Object.fromEntries(tags.value.map((tag) => [tag.keyword_id, tag]))
)

const attachedTags = computed(() =>
  [...tags.value].sort((a, b) =>
    (a.keyword?.name ?? '').localeCompare(b.keyword?.name ?? '')
  )
)

const unattachedKeywords = computed(() =>
  availableKeywords.value.filter((k) => !tagsByKeywordId.value[k.id])
)

function loadAvailableKeywords() {
  return Tag.all({ tag_object_type: props.objectType, per: 500 })
    .then(({ body }) => {
      const seen = new Map()
      body.forEach((tag) => {
        if (tag.keyword && !seen.has(tag.keyword.id)) {
          seen.set(tag.keyword.id, tag.keyword)
        }
      })
      availableKeywords.value = [...seen.values()].sort((a, b) =>
        (a.name ?? '').localeCompare(b.name ?? '')
      )
    })
    .catch(() => {})
}

function loadTagsForObject(objectId) {
  return Tag.all({
    tag_object_type: props.objectType,
    tag_object_id: objectId,
    per: 100
  })
    .then(({ body }) => {
      tags.value = body
    })
    .catch(() => {
      tags.value = []
    })
}

function keywordPillStyle(keyword) {
  const c = keyword?.css_color
  if (!c) return null
  return {
    backgroundColor: c,
    color: c
  }
}

function keywordOutlineStyle(keyword) {
  const c = keyword?.css_color
  if (!c) return null
  return {
    backgroundColor: `color-mix(in srgb, ${c} 18%, transparent)`,
    color: c,
    borderColor: c
  }
}

function attachKeyword(keyword) {
  if (!props.objectId || tagsByKeywordId.value[keyword.id]) return
  busy.value = true
  Tag.create({
    tag: {
      keyword_id: keyword.id,
      tag_object_type: props.objectType,
      tag_object_id: props.objectId
    }
  })
    .then(({ body }) => {
      const created = body.keyword ? body : { ...body, keyword }
      tags.value = [...tags.value, created]
    })
    .catch(() => {})
    .finally(() => {
      busy.value = false
    })
}

function removeTag(tag) {
  busy.value = true
  Tag.destroy(tag.id)
    .then(() => {
      tags.value = tags.value.filter((t) => t.id !== tag.id)
    })
    .catch(() => {})
    .finally(() => {
      busy.value = false
    })
}

watch(
  () => props.objectType,
  () => {
    loadAvailableKeywords()
  },
  { immediate: true }
)

watch(
  () => props.objectId,
  (id) => {
    if (id) loadTagsForObject(id)
    else tags.value = []
  },
  { immediate: true }
)
</script>

<style scoped>
.tag-remove {
  margin-left: 0.25em;
  font-weight: bold;
}

.keyword-clickable {
  cursor: pointer;
  user-select: none;
}

.keyword-clickable:hover {
  opacity: 0.85;
}

.keyword-outline {
  background-color: color-mix(in srgb, var(--text-muted-color) 18%, transparent);
  border: 1px solid currentColor;
  color: var(--text-muted-color);
}

.keyword-outline > span {
  color: inherit;
  filter: none;
}
</style>
