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
          <div class="flex-row gap-medium middle">
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
            <span>Selected: {{ store.selectedIds.length }}</span>
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

            <div
              v-for="type in store.objectType"
              :key="type"
              class="flex-row middle"
            >
              <span class="margin-medium-right">
                {{ type.match(/[A-Z]/g).join('') }}
              </span>
              <div class="square-brackets">
                <div class="flex-row gap-small">
                  <RadialBatch
                    :ids="store.getSelectedIdsByObjectType(type)"
                    :object-type="type"
                  />

                  <RadialFilter
                    :ids="store.getSelectedIdsByObjectType(type)"
                    :object-type="type"
                    :disabled="!store.selectedIds.length"
                    :extended-slices="[getExtendedFilter(type)]"
                  />

                  <component
                    :is="getRadialComponent(type)"
                    :ids="store.getSelectedIdsByObjectType(type)"
                  />
                </div>
              </div>
            </div>

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
import RadialBatch from '@/components/radials/mass/radial.vue'
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
