<template>
  <h1>Simple new specimen</h1>
  <BlockLayout>
    <template #header>
      <h3>Form</h3>
    </template>
    <template #body>
      <div
        class="margin-medium-bottom"
        id="collection-object-form"
      >
        <FormCatalogNumber />
        <FormPreparationType />
        <FormDetermination />
        <FormDepictions />
      </div>
      <FormCE />
    </template>
  </BlockLayout>
</template>

<script setup>
import FormCE from './components/FormCE.vue'
import FormPreparationType from './components/FormPreparationType.vue'
import FormCatalogNumber from './components/FormCatalogNumber.vue'
import FormDepictions from './components/FormDepictions.vue'
import FormDetermination from './components/FormDetermination.vue'
import BlockLayout from 'components/layout/BlockLayout.vue'
</script>

<style lang="scss">
#vue-simple-new-specimen {
  flex-direction: column-reverse;
  margin: 0 auto;
  margin-top: 1em;
  max-width: 1240px;

  #collection-object-form {
    display: grid;
    grid-template-columns: repeat(2, minmax(250px, 1fr) );
    gap: 1em;
    grid-auto-flow: dense;
  }

  hr {
    height: 1px;
    color: #f5f5f5;
    background: #f5f5f5;
    font-size: 0;
    margin: 15px;
    border: 0;
  }
}
</style>
