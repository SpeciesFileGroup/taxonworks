<template>
  <div>
    <div v-if="navList">
      <h3>Current</h3>
      <div class="flex-separate middle">
        {{ navList.current_otu.object_label }}
        <div class="horizontal-left-content gap-small">
          <RadialOtu :global-id="navList.current_otu.global_id" />
          <RadialAnnotator :global-id="navList.current_otu.global_id" />
          <RadialObject :global-id="navList.current_otu.global_id" />
        </div>
      </div>
      <template v-if="navList.parent_otus.length">
        <h4>Parent</h4>
        <ul class="no_bullets">
          <li
            v-for="item in navList.parent_otus"
            :key="item.id"
          >
            <a :href="browseLink(item)">
              {{ item.object_label }}
            </a>
          </li>
        </ul>
      </template>
      <template v-if="navList.previous_otus.length">
        <h4>Previous</h4>
        <ul class="no_bullets">
          <li
            v-for="item in navList.previous_otus"
            :key="item.id"
          >
            <a :href="browseLink(item)">
              {{ item.object_label }}
            </a>
          </li>
        </ul>
      </template>
      <template v-if="navList.next_otus.length">
        <h4>Next</h4>
        <ul class="no_bullets">
          <li
            v-for="item in navList.next_otus"
            :key="item.id"
          >
            <a :href="browseLink(item)">
              {{ item.object_label }}
            </a>
          </li>
        </ul>
      </template>
    </div>
  </div>
</template>

<script setup>
import { Otu } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'
import { ref, watch } from 'vue'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialObject from '@/components/radials/navigation/radial'
import RadialOtu from '@/components/radials/object/radial'

const props = defineProps({
  otuId: {
    type: [String, Number],
    default: undefined
  }
})

const navList = ref()

watch(
  () => props.otuId,
  (newVal) => {
    if (newVal) {
      loadNav(newVal)
    } else {
      navList.value = undefined
    }
  }
)

function loadNav(id) {
  Otu.navigation(id)
    .then((response) => {
      navList.value = response.body
    })
    .catch(() => {})
}

function browseLink(item) {
  return `${RouteNames.BrowseAssertedDistribution}?otu_id=${item.id}`
}
</script>
