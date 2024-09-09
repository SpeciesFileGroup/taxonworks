<template>
  <VNavbar>
    <div class="flex-separate middle">
      <div>
        <div
          v-if="store.container.id"
          class="horizontal-left-content middle gap-small"
        >
          <span v-html="store.container.objectTag" />
          <RadialAnnotator :global-id="store.container.globalId" />
          <RadialNavigator
            :global-id="store.container.globalId"
            :redirect="false"
            @delete="store.$reset()"
          />
        </div>
        <VAutocomplete
          v-else
          url="/containers/autocomplete"
          placeholder="Search a container..."
          param="term"
          label="label"
          @get-item="getContainer"
        />
      </div>
      <div class="horizontal-left-content gap-small">
        <VIcon
          v-if="store.hasUnsavedChanges"
          name="attention"
          small
          color="attention"
          title="You have unsaved changes."
        />
        <VBtn
          color="create"
          medium
          :disabled="!isSaveEnable"
          @click="save"
        >
          {{ store.container.id ? 'Update' : 'Create' }}
        </VBtn>
        <VBtn
          color="primary"
          medium
          @click="store.$reset()"
        >
          New
        </VBtn>
      </div>
    </div>
  </VNavbar>
</template>
<script setup>
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VNavbar from '@/components/layout/NavBar.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { useContainerStore } from '../../store'
import { setParam, URLParamsToJSON } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import { computed, watch } from 'vue'
import { usePopstateListener } from '@/composables'

const store = useContainerStore()

const isSaveEnable = computed(() => store.container.type)

function getContainer({ id }) {
  store.$reset()
  store.loadContainer(id)
  setParam(RouteNames.NewContainer, 'container_id', id)
}

async function save() {
  try {
    await store.saveContainer()
    store.saveContainerItems()
  } catch {}
}

watch(
  () => store.container.id,
  (newVal, oldVal) => {
    if (newVal !== oldVal) {
      setParam(RouteNames.NewContainer, 'container_id', newVal)
    }
  }
)

usePopstateListener(() => {
  const { container_id: id } = URLParamsToJSON(location.href)

  store.$reset()

  if (id) {
    store.loadContainer(id)
  }
})
</script>
