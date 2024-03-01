<template>
  <div class="panel content">
    <h2>
      Use the options below to build attributions and depictions, then
      <i>Apply</i> them to your images.
    </h2>
    <div class="horizontal-left-content items-stretch">
      <div class="separate-right full_width">
        <div class="horizontal-left-content">
          <input
            class="input-apply"
            disabled="true"
            :value="tagsLabel"
            type="text"
          />
          <button
            type="button"
            :disabled="!tags.length || !areImagesCreated"
            class="button normal-input button-submit separate-left"
            @click="applyTags"
          >
            Apply
          </button>
        </div>
        <div class="horizontal-left-content margin-small-top">
          <input
            class="input-apply"
            disabled="true"
            :value="showSource"
            type="text"
          />
          <button
            type="button"
            :disabled="!source || !areImagesCreated"
            class="button normal-input button-submit separate-left"
            @click="applySource"
          >
            Apply
          </button>
        </div>
        <div class="horizontal-left-content margin-small-top">
          <input
            class="input-apply"
            disabled="true"
            :value="showPeopleAndLicense"
            type="text"
          />
          <button
            type="button"
            :disabled="!validateAttr || !areImagesCreated"
            class="button normal-input button-submit separate-left"
            @click="applyAttr"
          >
            Apply
          </button>
        </div>
        <div class="horizontal-left-content margin-small-top">
          <input
            class="input-apply"
            disabled="true"
            :value="objectsForDepictions"
            type="text"
          />
          <button
            type="button"
            :disabled="
              !((validateDepic || validateSqedObject) && areImagesCreated)
            "
            class="button normal-input button-submit separate-left"
            @click="applyDepic"
          >
            Apply
          </button>
        </div>
        <div class="horizontal-left-content margin-small-top">
          <input
            class="input-apply"
            disabled="true"
            :value="showPixelToCm"
            type="text"
          />
          <button
            type="button"
            :disabled="!pixels || !areImagesCreated"
            class="button normal-input button-submit separate-left"
            @click="applyPxToCm"
          >
            Apply
          </button>
        </div>
      </div>
      <button
        class="button normal-input button-submit button-apply-both"
        type="button"
        :disabled="
          !(
            (validateDepic ||
              validateSqedObject ||
              validateAttr ||
              pixels ||
              source) &&
            areImagesCreated
          )
        "
        @click="
          () => {
            applyTags()
            applyAttr()
            applyDepic()
            applyPxToCm()
            applySource()
          }
        "
      >
        Apply all
      </button>
    </div>
  </div>
</template>

<script>
import { GetterNames } from '../store/getters/getters.js'
import { ActionNames } from '../store/actions/actions.js'
import validateSqed from '../helpers/validateSqed'

export default {
  computed: {
    source() {
      return this.$store.getters[GetterNames.GetSource]
    },

    tags() {
      return this.$store.getters[GetterNames.GetTagsForImage]
    },

    validateSqedObject() {
      return validateSqed(this.getSqed)
    },

    getYear() {
      return this.$store.getters[GetterNames.GetYearCopyright]
    },

    getSqed() {
      return this.$store.getters[GetterNames.GetSqed]
    },

    imagesCreated() {
      return this.$store.getters[GetterNames.GetImagesCreated]
    },

    areImagesCreated() {
      return this.$store.getters[GetterNames.GetImagesCreated].length > 0
    },

    validateDepic() {
      return this.$store.getters[GetterNames.GetObjectsForDepictions].length > 0
    },

    validateAttr() {
      return (
        this.areImagesCreated &&
        (this.license.length ||
          this.authors.length ||
          this.owners.length ||
          this.editors.length ||
          this.copyrightHolder.length ||
          this.getYear)
      )
    },

    authors() {
      return this.$store.getters[GetterNames.GetPeople].authors
    },

    editors() {
      return this.$store.getters[GetterNames.GetPeople].editors
    },

    owners() {
      return this.$store.getters[GetterNames.GetPeople].owners
    },

    copyrightHolder() {
      return this.$store.getters[GetterNames.GetPeople].copyrightHolder
    },

    license() {
      const lic = this.$store.getters[GetterNames.GetLicense]

      return lic
        ? `License: ${this.$store.getters[GetterNames.GetLicense]}`
        : ''
    },

    imagesBy() {
      const people = [].concat(
        this.getNames(this.authors),
        this.getNames(this.editors),
        this.getNames(this.owners),
        this.getNames(this.copyrightHolder)
      )

      return people.length ? `Image(s) by ${people.join('; ')}.` : ''
    },

    pixels() {
      return this.$store.getters[GetterNames.GetPixels]
    },

    showPixelToCm() {
      return this.pixels
        ? `A scale of ${this.pixels} pixels per centimeter will be added`
        : 'The scale of pixels per centimeter will be displayed here when defined.'
    },

    showPeopleAndLicense() {
      if (this.imagesBy.length || this.license.length) {
        return `${this.imagesBy}${this.imagesBy.length > 0 ? ' ' : ''}${
          this.license ? `${this.license}. ` : ''
        }${this.getYear ? ` Copyright year ${this.getYear}` : ''}`
      }
      return 'The attribution summary will be displayed here when defined.'
    },

    showSource() {
      return this.source
        ? `Source: ${this.source.cached}`
        : 'Source will be displayed here when defined.'
    },

    objectsForDepictions() {
      if (!this.validateDepic) {
        return 'A depiction summary will be displayed here when defined. Otherwise a new collection object will be created for each image.'
      }

      const depìctObjects = this.$store.getters[
        GetterNames.GetObjectsForDepictions
      ].map((item) => item.label)

      return depìctObjects.length
        ? `Depicts some: ${depìctObjects.join(', ')}`
        : 'A depiction summary will be displayed here when defined.'
    },

    tagsLabel() {
      return this.tags.length
        ? this.tags.map((t) => t.name).join('; ')
        : 'Tags summary will be displayed here when defined.'
    }
  },
  methods: {
    getNames(list) {
      return list.map(
        (item) =>
          item.cached ||
          (item.person_attributes &&
            `${item.person_attributes?.last_name}, ${item.person_attributes?.first_name}`) ||
          item.name ||
          `${item.last_name}, ${item.first_name}`
      )
    },

    applyAttr() {
      if (this.validateAttr) {
        this.$store.dispatch(ActionNames.ApplyAttributions)
      }
    },

    applySource() {
      if (this.source) {
        this.$store.dispatch(ActionNames.ApplySource)
      }
    },

    applyDepic() {
      if (this.validateDepic || this.validateSqedObject) {
        this.$store.dispatch(ActionNames.ApplyDepictions)
      }
    },

    applyPxToCm() {
      if (this.pixels) {
        this.$store.dispatch(ActionNames.ApplyPixelToCentimeter)
      }
    },

    applyTags() {
      if (this.tags.length) {
        this.$store.dispatch(ActionNames.ApplyTags, {
          objectIds: this.imagesCreated.map((image) => image.id),
          objectType: 'Image'
        })
      }
    }
  }
}
</script>

<style scoped>
.input-apply {
  width: 100%;
  font-size: 110%;
  color: #000000;
}
</style>
