<template>
  <NavBar>
    <div class="flex-separate full_width">
      <div class="middle margin-small-left">
        <span
          class="margin-small-left"
        >
          <h3>{{ headerLabel }}</h3>
        </span>
      </div>
      <ul class="context-menu no_bullets">
        <li class="horizontal-right-content">
          <a
            href="/gazetteers"
            class="margin-small-right"
          >
            Gazetteers
          </a>

          <ProjectsButton
            v-if="projectsUserIsMemberOf.length > 1"
            :gz="gz"
            :projects-user-is-member-of="projectsUserIsMemberOf"
            v-model="selectedProjects"
            class="margin-large-right"
          />

          <VBtn
            :disabled="saveDisabled"
            @click="emit('saveGz')"
            class="button normal-input button-submit button-size margin-small-right"
            type="button"
          >
            {{ saveLabel }}
          </VBtn>

          <VBtn
            @click="emit('resetGz')"
            class="button normal-input button-default button-size"
            type="button"
          >
            New
          </VBtn>
        </li>
      </ul>
    </div>
  </NavBar>
</template>

<script setup>
import NavBar from '@/components/layout/NavBar.vue'
import ProjectsButton from './ProjectsButton.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { computed } from 'vue'

const props = defineProps({
  gz: {
    type: Object,
    default: () => ({})
  },
  saveDisabled: {
    type: Boolean,
    default: true
  },
  projectsUserIsMemberOf: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['saveGz', 'resetGz'])

const selectedProjects = defineModel({type: Array, required: true})

const headerLabel = computed(() => {
  return props.gz.id ? props.gz.name : 'New Gazetteer'
})

const saveLabel = computed(() => {
  return props.gz.id ? "Update" : "Save"
})
</script>

<style lang="scss" scoped>
.gzs-link {
  margin-right: 2em;
}
</style>
