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
          <IconWarning class="w-4 h-4 text-attention-color" />
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
import IconWarning from '@/components/Icon/IconWarning.vue'

const store = useStore()

const softValidation = computed(
  () => store.getters[GetterNames.GetSoftValidation]
)
</script>
