<template>
  Root otu:
  <a
    v-if="key.otu"
    :href="key.otu.object_url"
    v-html="key.otu.object_tag"
    class="otu"
    target="_blank"
  />
  <span
    v-else
    class="otu"
  >
    <i>No root otu.</i>
  </span>

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
    class="otu"
  >
    <template v-if="key.child_otus.length">
      Other otus:
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
      <i>No other otus.</i>
    </span>
  </span>
</template>

<script setup>
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
</script>

<style lang="scss" scoped>
.otus_button {
  margin-left: .5em;
}
.otu {
  margin-left: .5em;
}
</style>