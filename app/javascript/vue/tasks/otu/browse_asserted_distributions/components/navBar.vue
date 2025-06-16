<template>
  <div>
    <div v-if="navList">
      <h3>Current {{
          decapitalize(
            humanize(
              toSnakeCase(assertedDistributionObject.objectType)
            )
          )
        }}
      </h3>
      <div class="flex-separate middle">
        {{ navList.current.object_label }}
        <div class="horizontal-left-content">
          <QuickForms :global-id="navList.current.global_id" />
          <RadialAnnotator :global-id="navList.current.global_id" />
          <RadialNavigator :global-id="navList.current.global_id" />
        </div>
      </div>
      <template v-if="navList.parents.length">
        <h4>Parent</h4>
        <ul class="no_bullets">
          <li
            v-for="item in navList.parents"
            :key="item.id"
          >
            <a
              :href="browseLink(item)"
            >
              {{ item.object_label }}
            </a>
          </li>
        </ul>
      </template>
      <template v-if="navList.previous.length">
        <h4>Previous</h4>
        <ul class="no_bullets">
          <li
            v-for="item in navList.previous"
            :key="item.id"
          >
            <a
              :href="browseLink(item)"
            >
              {{ item.object_label }}
            </a>
          </li>
        </ul>
      </template>
      <template v-if="navList.next.length">
        <h4>Next</h4>
        <ul class="no_bullets">
          <li
            v-for="item in navList.next"
            :key="item.id"
          >
            <a
              :href="browseLink(item)"
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
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams'
import { ENDPOINTS_HASH } from '../const/endpoints'
import { decapitalize, humanize, toSnakeCase } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import { ref, watch } from 'vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import QuickForms from '@/components/radials/object/radial.vue'

const props = defineProps({
  assertedDistributionObject: {
    type: Object,
    default: undefined
  }
})

const navList = ref(undefined)

watch(() => props.assertedDistributionObject, (newVal) => {
  if (newVal) {
    loadNav(newVal)
  } else {
    navList.value = undefined
  }
})

function loadNav(o) {
  ENDPOINTS_HASH[o.objectType].navigation(o.id)
    .then(({ body }) => {
      navList.value = body
    })
    .catch(() => {})
}

function browseLink(item) {

  return `${RouteNames.BrowseAssertedDistribution}?${ID_PARAM_FOR[props.assertedDistributionObject.objectType]}=${item.id}`
}
</script>
