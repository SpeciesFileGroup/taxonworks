<template>
  <div class="unify-box">
    <transition name="bounce">
      <div
        v-if="isAvailable"
        class="unify-box-container panel content"
      >
        <div class="flex-separate middle">
          <div class="horizontal-left-content gap-small">
            <ButtonUnify
              :ids="selectedIds"
              :model="TAXON_NAME"
            />
            Unify taxon names
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import useInteractionStore from '../store/interaction'
import ButtonUnify from '@/components/ui/Button/ButtonUnify.vue'
import { TAXON_NAME } from '@/constants'

const store = useInteractionStore()

const selectedIds = computed(() =>
  Object.values(store.selected)
    .flat()
    .map((item) => item.id)
)
const isAvailable = computed(() => selectedIds.value.length === 2)
</script>

<style lang="scss" scoped>
.unify-box {
  position: absolute;
  left: 50%;
  top: -59px;
  transform: translateX(-50%);
}
.unify-box-container {
  background-color: var(--bg-foreground);
  transform-origin: center;
}
</style>
