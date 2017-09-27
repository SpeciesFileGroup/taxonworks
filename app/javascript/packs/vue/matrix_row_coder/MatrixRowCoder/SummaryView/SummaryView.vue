<template>
    <div class="summary-view" :class="{ 'summary-view--unsaved': isUnsaved, 'summary-view--saved-at-least-once': savedAtLeastOnce }">
        <h2 class="summary-view__title">{{ descriptor.title }}</h2>
        <p>
            <button @click="zoomIn" type="button">Zoom</button>
        </p>
        <div>
            <slot></slot>
        </div>
        <save-countdown v-bind:descriptor="descriptor"></save-countdown>
    </div>
</template>

<style src="./SummaryView.styl" lang="stylus"></style>

<script>
    import { MutationNames } from '../../store/mutations/mutations';
    import { GetterNames } from '../../store/getters/getters';

    import saveCountdown from '../SaveCountdown/SaveCountdown.vue';

    export default {
        name: "summary-view",
        props: ['descriptor'],
        computed: {
            isUnsaved: function() {
                return this.$store.getters[GetterNames.IsDescriptorUnsaved](this.$props.descriptor.id);
            },
            savedAtLeastOnce: function() {
                return this.$props.descriptor.hasSavedAtLeastOnce;
            }
        },
        methods: {
            zoomIn: function(event) {
                this.$store.commit(MutationNames.SetDescriptorZoom, {
                    descriptorId: this.descriptor.id,
                    isZoomed: true
                });
            }
        },
        components: {
            saveCountdown
        }
    };
</script>