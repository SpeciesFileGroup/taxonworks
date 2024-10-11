<template>
  <ul class="no_bullets context-menu">
    <li class="middle">
      <div class="role__legend in-project margin-small-right" />
      <span>In project</span>
    </li>
    <li class="middle">
      <div class="role__legend no-in-project margin-small-right" />
      <span>Not in project</span>
    </li>
    <li class="middle">
      <div class="role__legend community margin-small-right" />
      <span>Not community</span>
    </li>
  </ul>
</template>

<script setup>
</script>

<style lang="scss">
@import './RoleDescription.scss';

.role__legend {
  border-radius: 50%;
  width: 18px;
  height: 18px;

  &.community {
    background-color: $color-community;
  }

  &.in-project {
    background-color: $color-in-project;
  }

  &.no-in-project {
    background-color: $color-no-in-project;
  }
}
</style>
