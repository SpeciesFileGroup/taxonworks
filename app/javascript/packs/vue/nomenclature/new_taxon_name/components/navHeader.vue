<template>
  <div id="taxonNavBarSlot">
    <div
      id="taxonNavBar"
      class="separate-bottom">
      <div class="navbar panel basic-information">
        <div class="content">
          <div class="flex-separate">
            <ul class="no_bullets context-menu">
              <li
                class="navigation-item context-menu-option"
                v-for="(link, key, index) in menu"
                v-if="link">
                <a
                  data-turbolinks="false"
                  :class="{ active : (activePosition == index)}"
                  :href="'#' + key.toLowerCase().replace(' ','-')"
                  @click="activePosition = index">{{ key }}
                </a>
              </li>
            </ul>
            <form class="horizontal-center-content">
              <transition name="fade">
                <span
                  data-icon="warning"
                  title="You have unsaved changes."
                  class="medium-icon separate-right"
                  v-if="unsavedChanges"/>
              </transition>
              <pin-object
                v-if="taxon.id"
                :pin-object="taxon['pinboard_item']"
                :object-id="taxon.id"
                :type="taxon.type"/>
              <save-taxon-name
                v-if="taxon.id"
                class="normal-input button button-submit"/>
              <create-new-button />
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>

const saveTaxonName = require('./saveTaxonName.vue').default
const createNewButton = require('./createNewButton.vue').default
const GetterNames = require('../store/getters/getters').GetterNames

const pinObject = require('../../../components/pin.vue').default

export default {
  props: {
    menu: {
      type: Object,
      required: true
    }
  },
  components: {
    saveTaxonName,
    createNewButton,
    pinObject
  },
  computed: {
    unsavedChanges () {
      return (this.$store.getters[GetterNames.GetLastChange] > this.$store.getters[GetterNames.GetLastSave])
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    }
  },
  data: function () {
    return {
      activePosition: 0
    }
  },
  created: function () {
    $(document).ready(function () {
      $(window).scroll(function () {
        if ($(window).scrollTop() > 155) {
          $('#taxonNavBar').addClass('navbar-fixed-top')
        }

        if ($(window).scrollTop() < 162) {
          $('#taxonNavBar').removeClass('navbar-fixed-top')
        }
      })
    })
  }
}
</script>
<style lang="scss">
#taxonNavBar.navbar-fixed-top {
  top:0px;
  width: 1240px;
  z-index:200;
  position: fixed;
}
#taxonNavBarSlot {
  height: 67px;
}
#taxonNavBar {
  button {
    margin-left: 6px;
    min-width: 100px;
    width: 100%;
  }
  .taxonname {
    font-weight: 300;
  }
  .unsaved
  li {
    a {
      font-size: 13px;
    }
    a:first-child {
      padding-left: 0px;
    }
  }
}
</style>
