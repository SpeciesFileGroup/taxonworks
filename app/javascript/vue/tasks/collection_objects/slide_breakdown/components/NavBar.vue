<template>
  <NavBar>
    <div class="flex-separate full_width">
      <div class="middle gap-small">
        <RecentButton @select="openGridDigitizer" />
        <span
          v-if="sledImage.id"
          v-html="sledImage.object_tag"
        />
        <span v-else>New record</span>
        <template v-if="sledImage.id">
          <RadialAnnotator :global-id="sledImage.global_id" />
        </template>
      </div>
      <div class="horizontal-right-content">
        <ul class="context-menu">
          <li>
            <a
              v-if="navigation.previous"
              :href="`${RouteNames.GridDigitizer}?sled_image_id=${navigation.previous}`"
            >
              Previous
            </a>
            <a
              class="disabled"
              v-else
              >Previous
            </a>
          </li>
          <li>
            <a
              v-if="navigation.next"
              :href="`${RouteNames.GridDigitizer}?sled_image_id=${navigation.next}`"
            >
              Next
            </a>
            <a
              class="disabled"
              v-else
              >Next
            </a>
          </li>
        </ul>
      </div>
    </div>
  </NavBar>
</template>

<script setup>
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { NavigationSled } from '../request/resource'
import { computed, watch } from 'vue'
import { useStore } from 'vuex'
import { RouteNames } from '@/routes/routes'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import NavBar from '@/components/layout/NavBar'
import RecentButton from './RecentList.vue'

const store = useStore()
const sledImage = computed(() => store.getters[GetterNames.GetSledImage])
const navigation = computed({
  get() {
    return store.getters[GetterNames.GetNavigation]
  },
  set(value) {
    store.commit(MutationNames.SetNavigation, value)
  }
})

watch(sledImage, (newVal, oldVal) => {
  if (newVal.id && oldVal.id != newVal.id) {
    NavigationSled(sledImage.value.global_id).then(({ headers }) => {
      navigation.value.next = headers['navigation-next']?.[0]
      navigation.value.previous = headers['navigation-previous']?.[0]
    })
  }
})

function openGridDigitizer(item) {
  window.open(`${RouteNames.GridDigitizer}?sled_image_id=${item.id}`, '_self')
}
</script>
