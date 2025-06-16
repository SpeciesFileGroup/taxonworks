<template>
  <div>
    <div v-if="navigation">
      <h3>Current {{
          decapitalize(humanize(toSnakeCase(objectType)))
        }}
      </h3>
      <div class="flex-separate middle">
        {{ navigation.current.object_label }}
        <div class="horizontal-left-content gap-small">
          <RadialOtu :global-id="navigation.current.global_id" />
          <RadialAnnotator :global-id="navigation.current.global_id" />
          <RadialObject :global-id="navigation.current.global_id" />
        </div>
      </div>
      <template v-if="navigation.parents.length">
        <h4>Parent</h4>
        <ul class="no_bullets">
          <li
            v-for="item in navigation.parents"
            :key="item.id"
          >
            <a :href="browseLink(item)">
              {{ item.object_label }}
            </a>
          </li>
        </ul>
      </template>
      <template v-if="navigation.previous.length">
        <h4>Previous</h4>
        <ul class="no_bullets">
          <li
            v-for="item in navigation.previous"
            :key="item.id"
          >
            <a :href="browseLink(item)">
              {{ item.object_label }}
            </a>
          </li>
        </ul>
      </template>
      <template v-if="navigation.next.length">
        <h4>Next</h4>
        <ul class="no_bullets">
          <li
            v-for="item in navigation.next"
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
import { ENDPOINTS_HASH } from '../const/endpoints'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams'
import { RouteNames } from '@/routes/routes'
import { ref, watch } from 'vue'
import { toSnakeCase, humanize } from '@/helpers'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialObject from '@/components/radials/navigation/radial'
import RadialOtu from '@/components/radials/object/radial'

const props = defineProps({
  objectId: {
    type: [String, Number],
    default: undefined
  },

  objectType: {
    type: String,
    default: undefined
  }
})

const navigation = ref()

watch(
  () => props.objectId,
  (newVal) => {
    if (newVal) {
      loadNav(newVal)
    } else {
      navigation.value = undefined
    }
  }
)

function loadNav(id) {
  ENDPOINTS_HASH[props.objectType].navigation(id)
    .then((response) => {
      navigation.value = response.body
    })
    .catch(() => {})
}

function browseLink(item) {
  return `${RouteNames.BrowseAssertedDistribution}?${ID_PARAM_FOR[props.objectType]}=${item.id}`
}
</script>
