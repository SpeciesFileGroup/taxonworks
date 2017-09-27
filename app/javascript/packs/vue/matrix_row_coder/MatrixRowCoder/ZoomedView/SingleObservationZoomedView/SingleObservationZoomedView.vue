<template>
    <zoomed-view v-bind:descriptor="descriptor">
        <div class="single-observation-zoomed-view">
            <div class="single-observation-zoomed-view__descriptor-details">
                <h2 class="single-observation-zoomed-view__descriptor-title">{{ descriptor.title }}</h2>
                <slot></slot>
                <descriptor-details v-bind:descriptor="descriptor"></descriptor-details>
            </div>
            <div
                v-if="observation"
                class="single-observation-zoomed-view__observation-details">

                <observation-details v-bind:observation="observation"></observation-details>
            </div>
        </div>
    </zoomed-view>
</template>

<style src="./SingleObservationZoomedView.styl" lang="stylus"></style>

<script>
    import observationDetails from '../../ObservationDetails/ObservationDetails.vue';
    import descriptorDetails from '../../DescriptorDetails/DescriptorDetails.vue';
    import zoomedView from '../ZoomedView.vue';

    export default {
        name: 'single-observation-zoomed-view',
        props: ['descriptor', 'observation'],
        components: {
            observationDetails,
            descriptorDetails,
            zoomedView
        }
    };
</script>