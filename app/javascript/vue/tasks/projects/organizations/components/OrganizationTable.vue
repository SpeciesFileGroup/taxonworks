<template>
  <table class="full_width table-striped">
    <thead>
      <tr>
        <th>Organization</th>
        <th>Depictions</th>
        <th class="w-2" />
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="projectOrganization in projectOrganizations"
        :key="projectOrganization.id"
      >
        <td>
          <a :href="projectOrganization.organization.object_url">
            {{ projectOrganization.organization.object_tag }}
          </a>
        </td>
        <td>
          <div class="horizontal-left-content gap-small">
            <ImageViewer
              v-for="depiction in projectOrganization.depictions"
              :depiction="depiction"
              :key="depiction.id"
            >
              <template #default="{ url }">
                <img
                  class="project-organization-depiction"
                  :src="url"
                  :alt="projectOrganization.organization.object_label"
                />
              </template>
            </ImageViewer>
          </div>
        </td>
        <td>
          <div class="horizontal-left-content gap-small">
            <RadialAnnotator
              :global-id="projectOrganization.organization.global_id"
              @close="emit('refresh', projectOrganization)"
            />
            <VBtn
              class="circle-button"
              color="destroy"
              circle
              @click="emit('remove', projectOrganization)"
            >
              <VIcon
                name="trash"
                x-small
              />
            </VBtn>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'

defineProps({
  projectOrganizations: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['remove', 'refresh'])
</script>

<style scoped>
.project-organization-depiction {
  max-height: 40px;
  max-width: 120px;
}

.depiction-thumb-container {
  margin: 0px;
}
</style>
