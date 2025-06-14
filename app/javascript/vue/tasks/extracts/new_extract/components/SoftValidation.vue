<template>
  <div
    v-if="softValidation.length"
    class="panel content soft-validation-box validation-warning"
  >
    <div class="margin-medium-left">
      <h3>Soft validation</h3>
    </div>
    <div class="body">
      <ul class="no_bullets">
        <li v-for="item in softValidation">
          <VIcon
            name="attention"
            color="attention"
            small
          />
          <span v-html="item.message" />
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../store/getters/getters'
import VIcon from '@/components/ui/VIcon/index.vue'

const store = useStore()

const softValidation = computed(
  () => store.getters[GetterNames.GetSoftValidation]
)
</script>
