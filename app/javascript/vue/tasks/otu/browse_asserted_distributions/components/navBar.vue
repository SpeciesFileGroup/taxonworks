<template>
  <div>
    <div v-if="navList">
      <h3>Current</h3>
      <div class="flex-separate middle">
        {{ navList.current_otu.object_label }}
        <div class="horizontal-left-content">
          <QuickForms :global-id="navList.current_otu.global_id" />
          <RadialAnnotator :global-id="navList.current_otu.global_id" />
          <RadialNavigator :global-id="navList.current_otu.global_id" />
        </div>
      </div>
      <template v-if="navList.parent_otus.length">
        <h4>Parent</h4>
        <ul class="no_bullets">
          <li
            v-for="item in navList.parent_otus"
            :key="item.id"
          >
            <a
              :href="() => browseLink(item)"
            >
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
            <a
              :href="() => browseLink(item)"
            >
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
            <a
              :href="() => browseLink(item)"
            >
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
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import QuickForms from '@/components/radials/object/radial.vue'

const props = defineProps({
  otuId: {
    type: [String, Number],
    default: undefined
  }
})

const navList = ref(undefined)

watch(() => props.otuId, (newVal) => {
  if (newVal) {
    loadNav(newVal)
  } else {
    navList.value = undefined
  }
})

function loadNav(id) {
  Otu.navigation(id)
    .then(({ body }) => {
      navList.value = body
    })
    .catch(() => {})
}

function browseLink(item) {
  return `${RouteNames.BrowseAssertedDistribution}?otu_id=${item.id}`
}
</script>
