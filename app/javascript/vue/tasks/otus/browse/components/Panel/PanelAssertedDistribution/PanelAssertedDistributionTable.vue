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
                color="primary"
                circle
                @click.stop="() => emit('sort', column)"
              >
                <VIcon
                  name="alphabeticalSort"
                  title="Sort alphabetically"
                  x-small
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
import VIcon from '@/components/ui/VIcon/index.vue'

defineProps({
  list: {
    type: Array,
    required: true
  },

  columns: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['sort'])
</script>
