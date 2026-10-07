<template>
  <table class="full_width table-striped">
    <thead>
      <tr>
        <th class="w-2" />
        <th
          v-for="column in columns"
          :key="column"
          class="capitalize"
        >
          <slot
            :name="column"
            :column="column"
          >
            <div class="flex-row gap-small middle">
              {{ column }}
              <VBtn
                title="Sort alphabetically"
                icon
                variant="outline"
                @click.stop="() => emit('sort', column)"
              >
                <IconArrowUpDown
                  v-if="sortedColumn !== column"
                  class="w-4 h-4"
                />
                <IconArrowUpAZ
                  v-else-if="ascending"
                  class="w-4 h-4"
                />
                <IconArrowDownZA
                  v-else
                  class="w-4 h-4"
                />
              </VBtn>
            </div>
          </slot>
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in list"
        :key="item.id"
      >
        <td>
          <div class="horizontal-left-content gap-small">
            <RadialAnnotator :global-id="item.globalId" />
            <RadialNavigator :global-id="item.globalId" />
          </div>
        </td>
        <td
          v-for="column in columns"
          :key="column"
          v-html="item[column]"
        />
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconArrowUpAZ from '@/components/Icon/IconArrowUpAZ.vue'
import IconArrowDownZA from '@/components/Icon/IconArrowDownZA.vue'
import IconArrowUpDown from '@/components/Icon/IconArrowUpDown.vue'

defineProps({
  list: {
    type: Array,
    required: true
  },

  columns: {
    type: Array,
    required: true
  },

  sortedColumn: {
    type: String,
    default: null
  },

  ascending: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['sort'])
</script>
