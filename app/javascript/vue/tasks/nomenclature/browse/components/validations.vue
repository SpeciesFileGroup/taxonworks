<template>
  <soft-validations
    class="margin-medium-bottom"
    :validations="validations"/>
</template>

<script>

import SoftValidations from 'components/soft_validations/panel'
import AjaxCall from 'helpers/ajaxCall'

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
        promises.push(AjaxCall('get', '/soft_validations/validate', { params: { global_id: globalId } }).then(({ body }) => body))
      })

      Promise.all(promises).then((list) => {
        this.$set(this.validations, key, { list, title: key })
      })
    })
  }

}
</script>
