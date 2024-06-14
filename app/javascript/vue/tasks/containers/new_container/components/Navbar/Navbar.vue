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
        <VBtn
          color="create"
          medium
          @click="store.saveContainer"
        >
          {{ store.container.id ? 'Update' : 'Create' }}
        </VBtn>
        <VBtn
          color="primary"
          medium
          @click="store.newContainer()"
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
import { useContainerStore } from '../../store'
import { setParam } from '@/helpers'
import { RouteNames } from '@/routes/routes'

const store = useContainerStore()

function getContainer({ id }) {
  store.loadContainer(id)
  setParam(RouteNames.NewContainer, 'container_id', id)
}
</script>
