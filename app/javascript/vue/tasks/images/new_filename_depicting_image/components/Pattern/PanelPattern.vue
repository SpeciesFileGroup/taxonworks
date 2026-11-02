<template>
  <div ref="rootRef">
    <div ref="panelRef">
      <BlockLayout :warning="!store.isPatternValid">
        <template #header>
          <h3>Filename pattern</h3>
        </template>
        <template #body>
          <div class="flex-col gap-medium">
            <PatternPalette />
            <div class="flex-col gap-small">
              <div class="horizontal-left-content middle gap-small">
                <PatternComposition class="full_width" />
                <VBtn
                  circle
                  color="primary"
                  title="Clear pattern"
                  :disabled="!store.composition.length"
                  @click="store.clearComposition()"
                >
                  <VIcon
                    name="trash"
                    x-small
                  />
                </VBtn>
              </div>
              <code>{{ describeComposition(store.composition) }}</code>
              <ul
                v-if="store.compositionErrors.length"
                class="feedback feedback-thin feedback-warning margin-remove no_bullets"
              >
                <li
                  v-for="error in store.compositionErrors"
                  :key="error"
                  class="padding-small-left padding-small-right"
                >
                  {{ error }}
                </li>
              </ul>
            </div>
            <PatternExample />
          </div>
        </template>
      </BlockLayout>
    </div>
  </div>
</template>

<script setup>
import { useTemplateRef } from 'vue'
import { useStickyBelow } from '@/composables'
import { useStore } from '../../store/store'
import { describeComposition } from '../../utils/pattern'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import PatternPalette from './PatternPalette.vue'
import PatternComposition from './PatternComposition.vue'
import PatternExample from './PatternExample.vue'

const store = useStore()
const rootRef = useTemplateRef('rootRef')
const panelRef = useTemplateRef('panelRef')

useStickyBelow(rootRef, panelRef)
</script>
