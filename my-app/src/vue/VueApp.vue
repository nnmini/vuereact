// src/vue/VueApp.vue
<template>
  <div>
    <h1 v-if="authState.isAuthenticated">Hello Vue</h1>
    <h1 v-else>Loading...</h1>
  </div>
</template>

<script>
import { inject, onMounted, ref } from "vue";

export default {
  name: "VueApp",
  setup() {
    const oktaAuth = inject("oktaAuth");
    const authState = ref({ isAuthenticated: false });

    onMounted(async () => {
      const state = await oktaAuth.authStateManager.getAuthState();
      authState.value = state;
      if (!state.isAuthenticated) {
        oktaAuth.token.getWithRedirect({
          responseType: "token id_token",
          scopes: ["openid", "profile", "email"],
        });
      }
    });

    return { authState };
  },
};
</script>