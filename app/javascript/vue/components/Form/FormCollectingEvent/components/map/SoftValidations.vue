<template>
  <SoftValidation :validations="store.softValidations" />
</template>

<script setup>
import SoftValidation from '@/components/soft_validations/panel.vue'
import useSoftValidationStore from '../../store/softValidations.js'

const store = useSoftValidationStore()
</script>
