<template>
  <div class="tw-card">
    <div
      v-if="title || $slots.title || $slots.icon || $slots.actions"
      class="tw-card-header"
    >
      <span
        v-if="$slots.icon"
        class="card-icon-chip"
      >
        <slot name="icon" />
      </span>
      <h2 class="tw-card-title">
        <slot name="title">{{ title }}</slot>
      </h2>
      <div
        v-if="$slots.actions"
        class="tw-card-header-actions"
      >
        <slot name="actions" />
      </div>
    </div>
    <div class="tw-card-body">
      <slot />
    </div>
    <div
      v-if="$slots.footer"
      class="tw-card-footer"
    >
      <slot name="footer" />
    </div>
  </div>
</template>

<script setup>
// Admin-style card (see app/assets/stylesheets/base/_tw_card.scss).
// Slots: #icon (header chip), #title (overrides the title prop),
// #actions (right-aligned header controls), default (body), #footer.
defineProps({
  title: {
    type: String,
    default: undefined
  }
})
</script>
