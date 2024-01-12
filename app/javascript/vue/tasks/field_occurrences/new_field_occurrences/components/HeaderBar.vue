<template>
  <Navbar>
    <div class="flex-separate full_width">
      <div class="middle margin-small-left">
        <span
          v-if="store.fieldOccurrence.id"
          class="margin-small-left"
          v-html="store.fieldOccurrence.object_tag"
        />
        <span
          class="margin-small-left"
          v-else
        >
          New record
        </span>
        <div
          v-if="store.fieldOccurrence.id"
          class="horizontal-left-content margin-small-left gap-small"
        >
          <RadialAnnotator :global-id="store.fieldOccurrence.global_id" />
          <RadialObject :global-id="store.fieldOccurrence.global_id" />
        </div>
      </div>
      <ul class="context-menu no_bullets">
        <li class="horizontal-right-content">
          <span
            v-if="isUnsaved"
            class="medium-icon margin-small-right"
            title="You have unsaved changes."
            data-icon="warning"
          />
          <button
            type="button"
            class="button normal-input button-submit button-size margin-small-right"
            @click="save"
          >
            Save
          </button>
          <button
            type="button"
            class="button normal-input button-default button-size"
            @click="reset"
          >
            New
          </button>
        </li>
      </ul>
    </div>
  </Navbar>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import Navbar from '@/components/layout/NavBar.vue'
import useStore from '../store/store'
import { computed } from 'vue'

const store = useStore()
const isUnsaved = computed(() => true)

function save() {}

function reset() {}
</script>
