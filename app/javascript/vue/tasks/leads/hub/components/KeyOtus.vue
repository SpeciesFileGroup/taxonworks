<template>
  <span>
    <template v-if="key.otus_count > 0">
      Otus({{ key.otus_count }}), root:
    </template>
    <template v-else>
      <i>No otus in this key</i>
    </template>
  </span>
  <a
    v-if="key.otu"
    :href="key.otu.object_url"
    v-html="key.otu.object_tag"
    class="otu"
    target="_blank"
  />
  <span
    v-else-if="childOtusExist"
    class="otu"
  >
    <i>no root otu,</i>
  </span>

  <template v-if="childOtusExist">
    &nbsp;other:
    <span
      v-if="!key.child_otus"
      class="otus_button"
    >
      <LoadOtusButton
        @click="() => emit('loadOtusForKey')"
      />
    </span>
    <span
      v-else
    >
      <template v-if="key.child_otus.length">
        <a
          v-for="otu in key.child_otus"
          :key="otu.id"
          :href="otu.object_url"
          v-html="otu.object_tag"
          class="otu"
          target="_blank"
        />
      </template>
      <span v-else class="otu">
        <i>none</i>
      </span>
    </span>
  </template>
</template>

<script setup>
import { computed } from 'vue'
import LoadOtusButton from './LoadOtusButton.vue'

const props = defineProps({
  // 'key' isn't allowed as a prop.
  keyProp: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['loadOtusForKey'])

const key = props.keyProp

const childOtusExist = computed(() => {
  return key.otu_id ? key.otus_count > 1 : key.otus_count > 0
})
</script>

<style lang="scss" scoped>
.otus_button {
  margin-left: .5em;
}
.otu {
  margin-left: .5em;
}
</style>