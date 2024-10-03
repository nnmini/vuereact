// src/auth/OktaAuth.js
import { OktaAuth } from '@okta/okta-auth-js';

const oktaAuth = new OktaAuth({
  issuer: 'https://dev-14034212.okta.com/oauth2/default',
  clientId: '0oabhth3bncajHX4V5d7',
  redirectUri: window.location.origin + '/login/callback',
  scopes: ['openid', 'profile', 'email']
});

// Method to check authentication state and handle redirects
const checkAuthAndRedirect = async () => {
  const authState = await oktaAuth.authStateManager.getAuthState();
  if (!authState.isAuthenticated) {
    oktaAuth.token.getWithRedirect({
      responseType: 'token id_token',
      scopes: ['openid', 'profile', 'email'],
    });
  }
};

// Export both oktaAuth and the checkAuthAndRedirect method
export { oktaAuth, checkAuthAndRedirect };