<template>
  <NavBar>
    <div class="flex-separate full_width">
      <div class="middle margin-small-left">
        <span
          class="margin-small-left"
        >
          {{ headerLabel }}
        </span>
        <div
          v-if="gz.id"
          class="horizontal-left-content margin-small-left gap-small"
        >
          <VPin
            class="circle-button"
            :object-id="gz.id"
            type="Gazetteer"
          />
          <!-- TODO complains when undefined instead of "" or something-->
          <RadialAnnotator :global-id="gz.global_id" />
          <RadialNavigator :global-id="gz.global_id" />
        </div>
      </div>
      <ul class="context-menu no_bullets">
        <li class="horizontal-right-content">
          <!-- TODO -->
          <span
            v-if="false"
            class="medium-icon margin-small-right"
            title="You have unsaved changes."
            data-icon="warning"
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
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VPin from '@/components/ui/Button/ButtonPin.vue'
import { computed, ref } from 'vue'

const props = defineProps({
  gz: {
    type: Object,
    default: {}
  },
  saveDisabled: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['cloneGz', 'saveGz', 'resetGz'])

const headerLabel = computed(() => {
  return props.gz.id ? props.gz.name : 'New Gazetteer'
})

const saveLabel = computed(() => {
  return props.gz.id ? "Update" : "Save"
})
</script>