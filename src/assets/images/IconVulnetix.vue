<template lang="">
  <img
    :alt="alt"
    class="app-icon"
    :class="class"
    src="@images/logo.svg"
    :width="width"
    :height="height"
  />
</template>
<script>
export default {
  props: {
    alt: String,
    class: String,
    width: String,
    height: String,
  },
};
</script>
<style lang="scss">
.app-icon {
  height: auto;
}
</style>
