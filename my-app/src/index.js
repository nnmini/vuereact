// src/index.js

// Manually set the public path
if (typeof window !== 'undefined' && window.__INJECTED_PUBLIC_PATH_BY_SYSTEMJS__) {
  __webpack_public_path__ = window.__INJECTED_PUBLIC_PATH_BY_SYSTEMJS__;
}

import './router';
import { oktaAuth, checkAuthAndRedirect } from './auth/OktaAuth'; // Use named imports

// Function to handle the callback from Okta
const handleCallback = async () => {
  try {
    await oktaAuth.handleLoginRedirect();
  } catch (error) {
    console.error('Error handling login redirect:', error);
  }
};

// Check if the current URL is the callback URL
if (window.location.pathname === '/login/callback') {
  handleCallback();
} else {
  // Check if the user is authenticated before redirecting
  oktaAuth.authStateManager.subscribe((authState) => {
    if (!authState.isAuthenticated) {
      checkAuthAndRedirect();
    }
  });

  // Initialize Okta Authentication
  oktaAuth.authStateManager.updateAuthState();
}