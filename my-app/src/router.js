// src/router.js
import { registerApplication, start } from 'single-spa';
import React from 'react';
import { createRoot } from 'react-dom/client'; // Import createRoot
import { createApp } from 'vue';
import VueApp from './vue/VueApp.vue';
import ReactApp from './react/ReactApp.jsx';
import { oktaAuth } from './auth/OktaAuth'; // Use named import
import { Security } from '@okta/okta-react'; // Import Security component

// Define restoreOriginalUri callback
const restoreOriginalUri = async (_oktaAuth, originalUri) => {
  window.location.replace(originalUri || '/');
};

// Register Vue App
registerApplication({
  name: 'vue-app',
  app: () => Promise.resolve({
    bootstrap: [() => Promise.resolve()],
    mount: () => {
      const app = createApp(VueApp);
      app.provide('oktaAuth', oktaAuth); // Provide oktaAuth instance
      app.mount('#vue');
      return Promise.resolve();
    },
    unmount: () => {
      const vueInstance = document.getElementById('vue').__vue_app__;
      if (vueInstance) {
        vueInstance.unmount();
      }
      return Promise.resolve();
    },
  }),
  activeWhen: ['/vue'],
});

// Register React App
registerApplication({
  name: 'react-app',
  app: () => Promise.resolve({
    bootstrap: [() => Promise.resolve()],
    mount: () => {
      const container = document.getElementById('react');
      const root = createRoot(container); // Create a root
      root.render(
        <Security oktaAuth={oktaAuth} restoreOriginalUri={restoreOriginalUri}>
          <ReactApp />
        </Security>
      );
      return Promise.resolve();
    },
    unmount: () => {
      const container = document.getElementById('react');
      const root = createRoot(container);
      root.unmount();
      return Promise.resolve();
    },
  }),
  activeWhen: ['/react'],
});

// Start single-spa
start();