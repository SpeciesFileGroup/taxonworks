<template>
  <soft-validations
    class="margin-medium-bottom full_width"
    :validations="validations"/>
</template>

<script>

import SoftValidations from 'components/soft_validations/panel'
import { SoftValidation } from 'routes/endpoints'

export default {
  components: { SoftValidations },

  props: {
    globalIds: {
      type: Object,
      required: true
    }
  },

  data () {
    return {
      validations: {}
    }
  },

  created () {
    const keys = Object.keys(this.globalIds)

    keys.forEach(key => {
      const promises = []
      const section = this.globalIds[key]

      section.forEach(globalId => {
        promises.push(SoftValidation.find(globalId).then(({ body }) => body))
      })

      Promise.all(promises).then((list) => {
        const validationList = list.filter(item => item.soft_validations.length)

        if (validationList.length) {
          this.$set(this.validations, key, { list: validationList, title: key })
        }
      })
    })
  }

}
</script>
