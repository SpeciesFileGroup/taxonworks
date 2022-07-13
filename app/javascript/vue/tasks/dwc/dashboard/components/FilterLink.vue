<template>
  <a :href="link">
    <slot />
  </a>
</template>
<script setup>

import { RouteNames } from 'routes/routes'

const link = `${RouteNames.FilterCollectionObjects}?${new URL(window.location.href).searchParams.toString()}`
</script>
