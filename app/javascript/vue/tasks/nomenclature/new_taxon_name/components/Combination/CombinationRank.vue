<template>
  <draggable
    class="flex-wrap-column"
    v-model="rankGroup"
    :options="options"
    item-key="id"
    :group="options.group"
    :animation="options.animation"
    :filter="options.filter"
    @end="_"
    @add="_"
    @update="_"
    @start="_">
    <template #item="{ element, index }">
      <div
        class="horizontal-left-content middle"
        v-if="!element.value">
        <autocomplete
          url="/taxon_names/autocomplete"
          label="label_html"
          min="2"
          :disabled="disabled"
          clear-after
          :add-params="{ type: 'Protonym', 'nomenclature_group[]': nomenclatureGroup }"
          param="term"/>
        <span
          class="handle button circle-button button-submit"
          title="Press and hold to drag input"
          data-icon="w_scroll-v"/>
      </div>
      <div
        class="original-combination-item horizontal-left-content middle"
        v-else>
        <div>
          <span class="vue-autocomplete-input normal-input combination middle">
            <span v-html="element.object_tag"/>
          </span>
        </div>
        <span
          class="handle button circle-button button-submit"
          title="Press and hold to drag input"
          data-icon="w_scroll-v"/>
        <radialAnnotator :global-id="element.global_id"/>
        <span
          class="circle-button btn-delete"
          @click="removeCombination(element)"/>
      </div>
    </template>
  </draggable>
</template>

<script setup>

const props = defineProps({
  options: {
    type: Object,
    required: true
  },

  rankGroup: {
    type: Object,
    required: true
  },

  nomenclatureGroup: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

</script>
