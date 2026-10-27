<template>
  <div>
    <template
      v-for="(group, groupName, groupIndex) in groups"
      :key="groupName"
    >
      <div
        v-if="groupIndex >= startPosition.groupIndex"
        class="separate-top capitalize"
      >
        <ul class="no_bullets">
          <template
            v-for="(rank, rankIndex) in group"
            :key="rank.name"
          >
            <li v-if="isRankVisible({ groupIndex, rankIndex, rank })">
              <label>
                <input
                  v-model="ranksSelected"
                  :value="rank.name"
                  type="checkbox"
                />
                {{ rank.name }}
              </label>
            </li>
          </template>
        </ul>
      </div>
    </template>
    <VBtn
      class="separate-top"
      color="primary"
      medium
      @click="typicalUse = !typicalUse"
    >
      {{ typicalUse ? 'Show more ranks' : 'Show less ranks' }}
    </VBtn>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  taxonName: {
    type: Object,
    required: true
  },

  rankList: {
    type: Object,
    required: true
  },

  modelValue: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue'])

const typicalUse = ref(true)

const ranksSelected = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const groups = computed(
  () => props.rankList[props.taxonName.nomenclatural_code] || {}
)

const startPosition = computed(() => {
  let groupName
  let rankIndex

  for (const key in groups.value) {
    const index = groups.value[key].findIndex(
      (rank) => rank.name === props.taxonName.rank
    )

    if (index >= 0) {
      groupName = key
      rankIndex = index
      break
    }
  }

  return {
    groupIndex: Object.keys(groups.value).findIndex((key) => key === groupName),
    rankIndex
  }
})

function isRankVisible({ groupIndex, rankIndex, rank }) {
  if (
    groupIndex === startPosition.value.groupIndex &&
    rankIndex < startPosition.value.rankIndex
  ) {
    return false
  }

  return typicalUse.value ? rank.typical_use : true
}
</script>
