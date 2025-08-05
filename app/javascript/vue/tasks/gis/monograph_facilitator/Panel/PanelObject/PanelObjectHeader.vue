<template>
  <table class="header-groups">
    <thead>
      <tr>
        <th class="w-6">
          <input
            type="checkbox"
            v-model="toggleSelection"
          />
        </th>
        <th class="header-label">
          <div class="flex-row gap-medium">
            <VIcon
              class="cursor-pointer"
              :name="toggleListVisible ? 'arrowDown' : 'arrowRight'"
              x-small
              @click="
                () => {
                  toggleListVisible = !toggleListVisible
                }
              "
            />
            <span>Selected objects: {{ store.selectedIds.length }}</span>
          </div>
        </th>
        <th class="w-2">
          <div class="horizontal-right-content gap-medium">
            <VBtn
              color="primary"
              title="Invert the current selection"
              @click="store.invertSelection"
            >
              Invert
            </VBtn>
            <RadialFilter
              :ids="store.selectedIds"
              :object-type="store.objectType"
              :disabled="!store.selectedIds.length"
              :extended-slices="[getExtendedFilter(store.objectType)]"
            />
            <component
              :is="getRadialComponent(store.objectType)"
              :ids="store.selectedIds"
            />
            <VIcon
              class="cursor-pointer"
              :name="toggleHide ? 'hide' : 'show'"
              small
              @click="() => (toggleHide = !toggleHide)"
            />
          </div>
        </th>
      </tr>
    </thead>
  </table>
</template>

<script setup>
import { computed } from 'vue'
import { getRadialComponent } from '../../utils'
import { getExtendedFilter } from '../../utils'
import useStore from '../../store/store.js'
import VIcon from '@/components/ui/VIcon/index.vue'
import RadialFilter from '@/components/radials/filter/radial.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const store = useStore()

const toggleListVisible = computed({
  get: () => store.groups.every((g) => g.isListVisible),
  set: (value) => {
    store.groups.forEach((g) => {
      g.isListVisible = value
    })
  }
})

const toggleSelection = computed({
  get: () => store.objects.every((o) => store.selectedIds.includes(o.id)),
  set: (value) => {
    store.selectedIds = value ? store.objects.map((o) => o.id).reverse() : []
  }
})

const toggleHide = computed({
  get: () => store.objects.every((o) => store.hiddenIds.includes(o.id)),
  set: (value) => {
    store.hiddenIds = value ? store.objects.map((o) => o.id) : []
  }
})
</script>

<style scoped>
.header-groups {
  width: 100%;
  border-left: 4px solid transparent;

  th:hover {
    background-color: inherit;
  }
}

.header-label {
  padding-left: 0px;
  padding-right: 0px;
}
</style>
