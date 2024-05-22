<template>
  <h3 class="title-section">New</h3>
  <div class="panel content card-new">
    <a
      :href="RouteNames.NewLead"
      target="_blank"
    >
      Create a new key
    </a>
  </div>
</template>

<script setup>
import { RouteNames } from '@/routes/routes'
</script>

<style lang="scss" scoped>
.card-new {
  width: 250px;
  margin-bottom: 8px;
  margin-right: 8px;
  text-decoration: none;
  a {
    font-size: 16px;
  }
}
</style>
